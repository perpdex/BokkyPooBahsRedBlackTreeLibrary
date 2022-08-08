pragma solidity ^0.8.0;

// ----------------------------------------------------------------------------
// BokkyPooBah's Red-Black Tree Library v1.0-pre-release-a
//
// A Solidity Red-Black Tree binary search library to store and access a sorted
// list of unsigned integer data. The Red-Black algorithm rebalances the binary
// search tree, resulting in O(log n) insert, remove and search time (and ~gas)
//
// https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.
// ----------------------------------------------------------------------------

library BokkyPooBahsRedBlackTreeLibrary {
    struct Node {
        uint40 parent;
        uint40 left;
        uint40 right;
        bool red;
        uint128 userData; // use freely. this is for gas efficiency
    }

    struct Tree {
        uint40 root;
        mapping(uint40 => Node) nodes;
    }

    uint40 private constant EMPTY = 0;

    function first(Tree storage self) internal view returns (uint40 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            _key = treeMinimum(self, self.root);
        }
    }

    function last(Tree storage self) internal view returns (uint40 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            _key = treeMaximum(self, self.root);
        }
    }

    function next(Tree storage self, uint40 target)
        internal
        view
        returns (uint40 cursor)
    {
        require(target != EMPTY, "RBTL_N: target is empty");
        if (self.nodes[target].right != EMPTY) {
            cursor = treeMinimum(self, self.nodes[target].right);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].right) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function prev(Tree storage self, uint40 target)
        internal
        view
        returns (uint40 cursor)
    {
        require(target != EMPTY, "RBTL_P: target is empty");
        if (self.nodes[target].left != EMPTY) {
            cursor = treeMaximum(self, self.nodes[target].left);
        } else {
            cursor = self.nodes[target].parent;
            while (cursor != EMPTY && target == self.nodes[cursor].left) {
                target = cursor;
                cursor = self.nodes[cursor].parent;
            }
        }
    }

    function exists(Tree storage self, uint40 key)
        internal
        view
        returns (bool)
    {
        return
            (key != EMPTY) &&
            ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }

    function isEmpty(uint40 key) internal pure returns (bool) {
        return key == EMPTY;
    }

    function getEmpty() internal pure returns (uint256) {
        return EMPTY;
    }

    function getNode(Tree storage self, uint40 key)
        internal
        view
        returns (
            uint40 _returnKey,
            uint40 _parent,
            uint40 _left,
            uint40 _right,
            bool _red
        )
    {
        require(exists(self, key), "RBTL_GN: key not exist");
        return (
            key,
            self.nodes[key].parent,
            self.nodes[key].left,
            self.nodes[key].right,
            self.nodes[key].red
        );
    }

    function insert(
        Tree storage self,
        uint40 key,
        uint128 userData,
        function(uint40, uint40, uint256) view returns (bool) lessThan,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) internal {
        require(key != EMPTY, "RBTL_I: key is empty");
        require(!exists(self, key), "RBTL_I: key already exists");
        uint40 cursor = EMPTY;
        uint40 probe = self.root;
        self.nodes[key] = Node({
            parent: EMPTY,
            left: EMPTY,
            right: EMPTY,
            red: true,
            userData: userData
        });
        while (probe != EMPTY) {
            cursor = probe;
            if (lessThan(key, probe, data)) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key].parent = cursor;
        if (cursor == EMPTY) {
            self.root = key;
        } else if (lessThan(key, cursor, data)) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        aggregateRecursively(self, key, aggregate, data);
        insertFixup(self, key, aggregate, data);
    }

    function remove(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) internal {
        require(key != EMPTY, "RBTL_R: key is empty");
        require(exists(self, key), "RBTL_R: key not exist");
        uint40 probe;
        uint40 cursor;
        if (self.nodes[key].left == EMPTY || self.nodes[key].right == EMPTY) {
            cursor = key;
        } else {
            cursor = self.nodes[key].right;
            while (self.nodes[cursor].left != EMPTY) {
                cursor = self.nodes[cursor].left;
            }
        }
        if (self.nodes[cursor].left != EMPTY) {
            probe = self.nodes[cursor].left;
        } else {
            probe = self.nodes[cursor].right;
        }
        uint40 yParent = self.nodes[cursor].parent;
        self.nodes[probe].parent = yParent;
        if (yParent != EMPTY) {
            if (cursor == self.nodes[yParent].left) {
                self.nodes[yParent].left = probe;
            } else {
                self.nodes[yParent].right = probe;
            }
        } else {
            self.root = probe;
        }
        bool doFixup = !self.nodes[cursor].red;
        if (cursor != key) {
            replaceParent(self, cursor, key);
            self.nodes[cursor].left = self.nodes[key].left;
            self.nodes[self.nodes[cursor].left].parent = cursor;
            self.nodes[cursor].right = self.nodes[key].right;
            self.nodes[self.nodes[cursor].right].parent = cursor;
            self.nodes[cursor].red = self.nodes[key].red;
            (cursor, key) = (key, cursor);
            aggregateRecursively(self, key, aggregate, data);
        }
        if (doFixup) {
            removeFixup(self, probe, aggregate, data);
        }
        aggregateRecursively(self, yParent, aggregate, data);

        // Fixed a bug that caused the parent of empty nodes to be non-zero.
        // TODO: Fix it the right way.
        if (probe == EMPTY) {
            self.nodes[probe].parent = EMPTY;
        }
    }

    // https://arxiv.org/pdf/1602.02120.pdf
    // changes from original
    // - handle empty
    // - handle parent
    // - change root to black

    // to avoid stack too deep
    struct JoinParams {
        uint40 left;
        uint40 key;
        uint40 right;
        uint8 leftBlackHeight;
        uint8 rightBlackHeight;
        uint256 data;
    }

    // destructive func
    function joinRight(
        Tree storage self,
        JoinParams memory params,
        function(uint40, uint256) returns (bool) aggregate
    ) private returns (uint40, uint8) {
        if (
            !self.nodes[params.left].red &&
            params.leftBlackHeight == params.rightBlackHeight
        ) {
            self.nodes[params.key].red = true;
            self.nodes[params.key].left = params.left;
            self.nodes[params.key].right = params.right;
            aggregate(params.key, params.data);
            return (params.key, params.leftBlackHeight);
        }

        (uint40 t, ) = joinRight(
            self,
            JoinParams({
                left: self.nodes[params.left].right,
                key: params.key,
                right: params.right,
                leftBlackHeight: params.leftBlackHeight -
                    (self.nodes[params.left].red ? 0 : 1),
                rightBlackHeight: params.rightBlackHeight,
                data: params.data
            }),
            aggregate
        );
        self.nodes[params.left].right = t;
        self.nodes[params.left].parent = EMPTY;
        aggregate(params.left, params.data);

        if (
            !self.nodes[params.left].red &&
            self.nodes[t].red &&
            self.nodes[self.nodes[t].right].red
        ) {
            self.nodes[self.nodes[t].right].red = false;
            rotateLeft(self, params.left, aggregate, params.data);
            return (t, params.leftBlackHeight);
            //            return (self.nodes[params.left].parent, tBlackHeight + 1); // TODO: replace with t
        }
        return (params.left, params.leftBlackHeight);
        //        return (params.left, tBlackHeight + (self.nodes[params.left].red ? 0 : 1));
    }

    // destructive func
    function joinLeft(
        Tree storage self,
        JoinParams memory params,
        function(uint40, uint256) returns (bool) aggregate
    ) internal returns (uint40 resultKey) {
        if (
            !self.nodes[params.right].red &&
            params.leftBlackHeight == params.rightBlackHeight
        ) {
            self.nodes[params.key].red = true;
            self.nodes[params.key].left = params.left;
            self.nodes[params.key].right = params.right;
            if (params.left != EMPTY) {
                self.nodes[params.left].parent = params.key;
            }
            if (params.right != EMPTY) {
                self.nodes[params.right].parent = params.key;
            }
            aggregate(params.key, params.data);
            return params.key;
        }

        uint40 t = joinLeft(
            self,
            JoinParams({
                left: params.left,
                key: params.key,
                right: self.nodes[params.right].left,
                leftBlackHeight: params.leftBlackHeight,
                rightBlackHeight: params.rightBlackHeight -
                    (self.nodes[params.right].red ? 0 : 1),
                data: params.data
            }),
            aggregate
        );
        self.nodes[params.right].left = t;
        self.nodes[params.right].parent = EMPTY;
        if (t != EMPTY) {
            self.nodes[t].parent = params.right;
        }
        aggregate(params.right, params.data);

        if (
            !self.nodes[params.right].red &&
            self.nodes[t].red &&
            self.nodes[self.nodes[t].left].red
        ) {
            self.nodes[self.nodes[t].left].red = false;
            rotateRight(self, params.right, aggregate, params.data);
            return t;
        }
        return params.right;
    }

    // destructive func
    function join(
        Tree storage self,
        uint40 left,
        uint40 key,
        uint40 right,
        function(uint40, uint256) returns (bool) aggregate,
        uint8 leftBlackHeight,
        uint8 rightBlackHeight,
        uint256 data
    ) private returns (uint40 t, uint8 tBlackHeight) {
        if (leftBlackHeight > rightBlackHeight) {
            (t, tBlackHeight) = joinRight(
                self,
                JoinParams({
                    left: left,
                    key: key,
                    right: right,
                    leftBlackHeight: leftBlackHeight,
                    rightBlackHeight: rightBlackHeight,
                    data: data
                }),
                aggregate
            );
            tBlackHeight = leftBlackHeight;
            if (self.nodes[t].red && self.nodes[self.nodes[t].right].red) {
                self.nodes[t].red = false;
                tBlackHeight += 1;
            }
        } else if (leftBlackHeight < rightBlackHeight) {
            t = joinLeft(
                self,
                JoinParams({
                    left: left,
                    key: key,
                    right: right,
                    leftBlackHeight: leftBlackHeight,
                    rightBlackHeight: rightBlackHeight,
                    data: data
                }),
                aggregate
            );
            tBlackHeight = rightBlackHeight;
            if (self.nodes[t].red && self.nodes[self.nodes[t].left].red) {
                self.nodes[t].red = false;
                tBlackHeight += 1;
            }
        } else {
            bool red = !self.nodes[left].red && !self.nodes[right].red;
            self.nodes[key].red = red;
            self.nodes[key].left = left;
            self.nodes[key].right = right;
            aggregate(key, data);
            (t, tBlackHeight) = (key, leftBlackHeight + (red ? 0 : 1));
        }
    }

    struct SplitParams {
        uint40 t;
        uint40 key;
        uint8 blackHeight;
        uint256 data;
    }

    // destructive func
    function splitRight(
        Tree storage self,
        SplitParams memory params,
        function(uint40, uint40, uint256) returns (bool) lessThan,
        function(uint40, uint256) returns (bool) aggregate,
        function(uint40, uint256) subtreeRemoved
    ) private returns (uint40 resultKey, uint8 resultBlackHeight) {
        if (params.t == EMPTY) return (EMPTY, params.blackHeight);
        params.blackHeight -= (self.nodes[params.t].red ? 0 : 1);
        if (params.key == params.t) {
            subtreeRemoved(params.t, params.data);
            return (self.nodes[params.t].right, params.blackHeight);
        }
        if (lessThan(params.key, params.t, params.data)) {
            (uint40 r, uint8 rBlackHeight) = splitRight(
                self,
                SplitParams({
                    t: self.nodes[params.t].left,
                    key: params.key,
                    blackHeight: params.blackHeight,
                    data: params.data
                }),
                lessThan,
                aggregate,
                subtreeRemoved
            );
            return
                join(
                    self,
                    r,
                    params.t,
                    self.nodes[params.t].right,
                    aggregate,
                    rBlackHeight,
                    params.blackHeight,
                    params.data
                );
        } else {
            subtreeRemoved(params.t, params.data);
            return
                splitRight(
                    self,
                    SplitParams({
                        t: self.nodes[params.t].right,
                        key: params.key,
                        blackHeight: params.blackHeight,
                        data: params.data
                    }),
                    lessThan,
                    aggregate,
                    subtreeRemoved
                );
        }
    }

    function removeLeft(
        Tree storage self,
        uint40 key,
        function(uint40, uint40, uint256) returns (bool) lessThan,
        function(uint40, uint256) returns (bool) aggregate,
        function(uint40, uint256) subtreeRemoved,
        uint256 data
    ) internal {
        require(key != EMPTY, "RBTL_RL: key is empty");
        require(exists(self, key), "RBTL_RL: key not exist");
        (self.root, ) = splitRight(
            self,
            SplitParams({t: self.root, key: key, blackHeight: 128, data: data}),
            lessThan,
            aggregate,
            subtreeRemoved
        );
        self.nodes[self.root].parent = EMPTY;
        self.nodes[self.root].red = false;
    }

    function aggregateRecursively(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) internal {
        while (key != EMPTY) {
            if (aggregate(key, data)) return;
            key = self.nodes[key].parent;
        }
    }

    function treeMinimum(Tree storage self, uint40 key)
        private
        view
        returns (uint40)
    {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }

    function treeMaximum(Tree storage self, uint40 key)
        private
        view
        returns (uint40)
    {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) private {
        uint40 cursor = self.nodes[key].right;
        uint40 keyParent = self.nodes[key].parent;
        uint40 cursorLeft = self.nodes[cursor].left;
        self.nodes[key].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].left) {
            self.nodes[keyParent].left = cursor;
        } else {
            self.nodes[keyParent].right = cursor;
        }
        self.nodes[cursor].left = key;
        self.nodes[key].parent = cursor;
        aggregate(key, data);
        aggregate(cursor, data);
    }

    function rotateRight(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) private {
        uint40 cursor = self.nodes[key].left;
        uint40 keyParent = self.nodes[key].parent;
        uint40 cursorRight = self.nodes[cursor].right;
        self.nodes[key].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = key;
        }
        self.nodes[cursor].parent = keyParent;
        if (keyParent == EMPTY) {
            self.root = cursor;
        } else if (key == self.nodes[keyParent].right) {
            self.nodes[keyParent].right = cursor;
        } else {
            self.nodes[keyParent].left = cursor;
        }
        self.nodes[cursor].right = key;
        self.nodes[key].parent = cursor;
        aggregate(key, data);
        aggregate(cursor, data);
    }

    function insertFixup(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) private {
        uint40 cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            uint40 keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                        key = keyParent;
                        rotateLeft(self, key, aggregate, data);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateRight(
                        self,
                        self.nodes[keyParent].parent,
                        aggregate,
                        data
                    );
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[keyParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                        key = keyParent;
                        rotateRight(self, key, aggregate, data);
                    }
                    keyParent = self.nodes[key].parent;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[keyParent].parent].red = true;
                    rotateLeft(
                        self,
                        self.nodes[keyParent].parent,
                        aggregate,
                        data
                    );
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(
        Tree storage self,
        uint40 a,
        uint40 b
    ) private {
        uint40 bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function removeFixup(
        Tree storage self,
        uint40 key,
        function(uint40, uint256) returns (bool) aggregate,
        uint256 data
    ) private {
        uint40 cursor;
        while (key != self.root && !self.nodes[key].red) {
            uint40 keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateLeft(self, keyParent, aggregate, data);
                    cursor = self.nodes[keyParent].right;
                }
                if (
                    !self.nodes[self.nodes[cursor].left].red &&
                    !self.nodes[self.nodes[cursor].right].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor, aggregate, data);
                        cursor = self.nodes[keyParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, keyParent, aggregate, data);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[keyParent].red = true;
                    rotateRight(self, keyParent, aggregate, data);
                    cursor = self.nodes[keyParent].left;
                }
                if (
                    !self.nodes[self.nodes[cursor].right].red &&
                    !self.nodes[self.nodes[cursor].left].red
                ) {
                    self.nodes[cursor].red = true;
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor, aggregate, data);
                        cursor = self.nodes[keyParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[keyParent].red;
                    self.nodes[keyParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, keyParent, aggregate, data);
                    key = self.root;
                }
            }
        }
        self.nodes[key].red = false;
    }
}
// ----------------------------------------------------------------------------
// End - BokkyPooBah's Red-Black Tree Library
// ----------------------------------------------------------------------------
