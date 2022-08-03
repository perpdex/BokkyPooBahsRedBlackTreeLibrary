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
        uint80 parent;
        uint80 left;
        uint80 right;
        uint8 blackHeight; // from bottom
        bool red;
    }

    struct Tree {
        uint80 root;
        mapping(uint80 => Node) nodes;
    }

    uint80 private constant EMPTY = 0;

    function first(Tree storage self) internal view returns (uint80 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            _key = treeMinimum(self, self.root);
        }
    }
    function last(Tree storage self) internal view returns (uint80 _key) {
        _key = self.root;
        if (_key != EMPTY) {
            _key = treeMaximum(self, self.root);
        }
    }
    function next(Tree storage self, uint80 target) internal view returns (uint80 cursor) {
        require(target != EMPTY);
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
    function prev(Tree storage self, uint80 target) internal view returns (uint80 cursor) {
        require(target != EMPTY);
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
    function exists(Tree storage self, uint80 key) internal view returns (bool) {
        return (key != EMPTY) && ((key == self.root) || (self.nodes[key].parent != EMPTY));
    }
    function isEmpty(uint80 key) internal pure returns (bool) {
        return key == EMPTY;
    }
    function getEmpty() internal pure returns (uint) {
        return EMPTY;
    }
    function getNode(Tree storage self, uint80 key) internal view returns (uint80 _returnKey, uint80 _parent, uint80 _left, uint80 _right, bool _red, uint8 blackHeight) {
        require(exists(self, key));
        return(key, self.nodes[key].parent, self.nodes[key].left, self.nodes[key].right, self.nodes[key].red, self.nodes[key].blackHeight);
    }

    function insert(Tree storage self, uint80 key, function (uint80, uint80) view returns (bool) lessThan, function (uint80) returns (bool) aggregate) internal {
        require(key != EMPTY);
        require(!exists(self, key));
        uint80 cursor = EMPTY;
        uint80 probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (lessThan(key, probe)) {
                probe = self.nodes[probe].left;
            } else {
                probe = self.nodes[probe].right;
            }
        }
        self.nodes[key] = Node({parent: cursor, left: EMPTY, right: EMPTY, red: true, blackHeight: 1});
        if (cursor == EMPTY) {
            self.root = key;
        } else if (lessThan(key, cursor)) {
            self.nodes[cursor].left = key;
        } else {
            self.nodes[cursor].right = key;
        }
        _aggregateRecursive(self, cursor, aggregate);
        insertFixup(self, key, aggregate);
    }
    function remove(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) internal {
        require(key != EMPTY);
        require(exists(self, key));
        uint80 probe;
        uint80 cursor;
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
        uint80 yParent = self.nodes[cursor].parent;
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
            _aggregateRecursive(self, key, aggregate);
        }
        if (doFixup) {
            removeFixup(self, probe, aggregate);
        }
        _aggregateRecursive(self, yParent, aggregate);
    }

    // destructive func
    function joinRight(Tree storage self, uint80 left, uint80 key, uint80 right, function (uint80) returns (bool) aggregate) private returns (uint80) {
        uint8 leftBlackHeight = self.nodes[left].blackHeight;
        uint8 rightBlackHeight = self.nodes[right].blackHeight;

        if (!self.nodes[left].red && leftBlackHeight == rightBlackHeight) {
            _setRed(self, key, true);
            self.nodes[key].left = left;
            self.nodes[key].right = right;
            _aggregateBlackHeight(self, key);
            aggregate(key);
            return key;
        }

        uint80 t = joinRight(self, self.nodes[left].right, key, right, aggregate);
        self.nodes[left].right = t;
        _aggregateBlackHeight(self, left);
        aggregate(left);

        if (!self.nodes[left].red && self.nodes[t].red && self.nodes[self.nodes[t].right].red) {
            rotateLeft(self, left, aggregate);
            return self.nodes[left].parent;
        }
        return left;
    }

    // destructive func
    function joinLeft(Tree storage self, uint80 left, uint80 key, uint80 right, function (uint80) returns (bool) aggregate) internal returns (uint80) {
        uint8 leftBlackHeight = self.nodes[left].blackHeight;
        uint8 rightBlackHeight = self.nodes[right].blackHeight;

        if (!self.nodes[right].red && leftBlackHeight == rightBlackHeight) {
            _setRed(self, key, true);
            self.nodes[key].left = left;
            self.nodes[key].right = right;
            _aggregateBlackHeight(self, key);
            aggregate(key);
            return key;
        }

        uint80 t = joinLeft(self, left, key, self.nodes[right].left, aggregate);
        self.nodes[right].left = t;
        _aggregateBlackHeight(self, right);
        aggregate(right);

        if (!self.nodes[right].red && self.nodes[t].red && self.nodes[self.nodes[t].right].red) {
            rotateRight(self, right, aggregate);
            return self.nodes[right].parent;
        }
        return right;
    }

    // destructive func
    function join(Tree storage self, uint80 left, uint80 key, uint80 right, function (uint80) returns (bool) aggregate) private returns (uint80) {
        uint8 leftBlackHeight = self.nodes[left].blackHeight;
        uint8 rightBlackHeight = self.nodes[right].blackHeight;

        if (leftBlackHeight > rightBlackHeight) {
            uint80 t = joinRight(self, left, key, right, aggregate);
            if (self.nodes[t].red && self.nodes[self.nodes[t].right].red) {
                _setRed(self, t, false);
            }
            return t;
        } else if (leftBlackHeight < rightBlackHeight) {
            uint80 t = joinLeft(self, left, key, right, aggregate);
            if (self.nodes[t].red && self.nodes[self.nodes[t].left].red) {
                _setRed(self, t, false);
            }
            return t;
        } else {
            _setRed(self, key, !self.nodes[left].red && !self.nodes[right].red);
            self.nodes[key].left = left;
            self.nodes[key].right = right;
            _aggregateBlackHeight(self, key);
            aggregate(key);
            return key;
        }
    }

    // destructive func
    function splitRight(Tree storage self, uint80 t, uint80 key, function (uint80, uint80) returns (bool) lessThan, function (uint80) returns (bool) aggregate)
    private returns (uint80 rightKey, uint8 blackHeight) {
        if (t == EMPTY) return EMPTY;
        if (lessThan(key, t)) {
            uint80 r = splitRight(self, self.nodes[t].left, key, lessThan, aggregate);
            rightKey = join(self, r, t, self.nodes[t].right, aggregate);
        } else {
            (rightKey, blackHeight) = splitRight(self, self.nodes[t].right, key, lessThan, aggregate);
        }
    }

    function removeLeft(Tree storage self, uint80 key, function (uint80, uint80) returns (bool) lessThan, function (uint80) returns (bool) aggregate) internal {
        self.root = splitRight(self, self.root, key, lessThan, aggregate);
    }

    function _aggregateRecursive(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) private {
        bool stopped;
        bool stoppedBlackHeight;
        while (key != EMPTY) {
//            if (!stoppedBlackHeight) {
                stoppedBlackHeight = _aggregateBlackHeight(self, key);
//            }
            if (!stopped) {
                stopped = aggregate(key);
            }
//            if (stopped && stoppedBlackHeight) return;
            key = self.nodes[key].parent;
        }
    }

    function treeMinimum(Tree storage self, uint80 key) private view returns (uint80) {
        while (self.nodes[key].left != EMPTY) {
            key = self.nodes[key].left;
        }
        return key;
    }
    function treeMaximum(Tree storage self, uint80 key) private view returns (uint80) {
        while (self.nodes[key].right != EMPTY) {
            key = self.nodes[key].right;
        }
        return key;
    }

    function rotateLeft(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) private {
        uint80 cursor = self.nodes[key].right;
        uint80 keyParent = self.nodes[key].parent;
        uint80 cursorLeft = self.nodes[cursor].left;
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
        _aggregateBlackHeight(self, key);
        aggregate(key);
        _aggregateBlackHeight(self, cursor);
        aggregate(cursor);
    }
    function rotateRight(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) private {
        uint80 cursor = self.nodes[key].left;
        uint80 keyParent = self.nodes[key].parent;
        uint80 cursorRight = self.nodes[cursor].right;
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
        _aggregateBlackHeight(self, key);
        aggregate(key);
        _aggregateBlackHeight(self, cursor);
        aggregate(cursor);
    }

    function insertFixup(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) private {
        uint80 cursor;
        while (key != self.root && self.nodes[self.nodes[key].parent].red) {
            uint80 keyParent = self.nodes[key].parent;
            if (keyParent == self.nodes[self.nodes[keyParent].parent].left) {
                cursor = self.nodes[self.nodes[keyParent].parent].right;
                if (self.nodes[cursor].red) {
                    _setRed(self, keyParent, false);
                    _setRed(self, cursor, false);
                    _setRed(self, self.nodes[keyParent].parent, true);
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].right) {
                      key = keyParent;
                      rotateLeft(self, key, aggregate);
                    }
                    keyParent = self.nodes[key].parent;
                    _setRed(self, keyParent, false);
                    _setRed(self, self.nodes[keyParent].parent, true);
                    rotateRight(self, self.nodes[keyParent].parent, aggregate);
                }
            } else {
                cursor = self.nodes[self.nodes[keyParent].parent].left;
                if (self.nodes[cursor].red) {
                    _setRed(self, keyParent, false);
                    _setRed(self, cursor, false);
                    _setRed(self, self.nodes[keyParent].parent, true);
                    key = self.nodes[keyParent].parent;
                } else {
                    if (key == self.nodes[keyParent].left) {
                      key = keyParent;
                      rotateRight(self, key, aggregate);
                    }
                    keyParent = self.nodes[key].parent;
                    _setRed(self, keyParent, false);
                    _setRed(self, self.nodes[keyParent].parent, true);
                    rotateLeft(self, self.nodes[keyParent].parent, aggregate);
                }
            }
        }
        _setRed(self, self.root, false);
    }

    function replaceParent(Tree storage self, uint80 a, uint80 b) private {
        uint80 bParent = self.nodes[b].parent;
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
    function removeFixup(Tree storage self, uint80 key, function (uint80) returns (bool) aggregate) private {
        uint80 cursor;
        while (key != self.root && !self.nodes[key].red) {
            uint80 keyParent = self.nodes[key].parent;
            if (key == self.nodes[keyParent].left) {
                cursor = self.nodes[keyParent].right;
                if (self.nodes[cursor].red) {
                    _setRed(self, cursor, false);
                    _setRed(self, keyParent, true);
                    rotateLeft(self, keyParent, aggregate);
                    cursor = self.nodes[keyParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    _setRed(self, cursor, true);
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        _setRed(self, self.nodes[cursor].left, false);
                        _setRed(self, cursor, true);
                        rotateRight(self, cursor, aggregate);
                        cursor = self.nodes[keyParent].right;
                    }
                    _setRed(self, cursor, self.nodes[keyParent].red);
                    _setRed(self, keyParent, false);
                    _setRed(self, self.nodes[cursor].right, false);
                    rotateLeft(self, keyParent, aggregate);
                    key = self.root;
                }
            } else {
                cursor = self.nodes[keyParent].left;
                if (self.nodes[cursor].red) {
                    _setRed(self, cursor, false);
                    _setRed(self, keyParent, true);
                    rotateRight(self, keyParent, aggregate);
                    cursor = self.nodes[keyParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    _setRed(self, cursor, true);
                    key = keyParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        _setRed(self, self.nodes[cursor].right, false);
                        _setRed(self, cursor, true);
                        rotateLeft(self, cursor, aggregate);
                        cursor = self.nodes[keyParent].left;
                    }
                    _setRed(self, cursor, self.nodes[keyParent].red);
                    _setRed(self, keyParent, false);
                    _setRed(self, self.nodes[cursor].left, false);
                    rotateRight(self, keyParent, aggregate);
                    key = self.root;
                }
            }
        }
        _setRed(self, key, false);
    }

    function _setRed(Tree storage self, uint80 key, bool red) private {
        if (self.nodes[key].red != red) {
            self.nodes[key].red = red;
            self.nodes[key].blackHeight = red ?
                self.nodes[key].blackHeight - 1 :
                self.nodes[key].blackHeight + 1;
        }
    }

    function _aggregateBlackHeight(Tree storage self, uint80 key) private returns (bool) {
        Node memory node = self.nodes[key];
        uint8 blackHeight = (
        (node.left == EMPTY || node.right == EMPTY) ?
        1
        :
        self.nodes[node.left].blackHeight)
        + (node.red ? 0 : 1);
        if (node.blackHeight == blackHeight) {
            return true;
        } else {
            self.nodes[key].blackHeight = blackHeight;
            return false;
        }
    }
}
// ----------------------------------------------------------------------------
// End - BokkyPooBah's Red-Black Tree Library
// ----------------------------------------------------------------------------
