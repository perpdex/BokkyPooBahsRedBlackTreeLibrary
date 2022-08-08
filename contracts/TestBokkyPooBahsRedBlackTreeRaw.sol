pragma solidity ^0.8.0;

import "./BokkyPooBahsRedBlackTreeLibrary.sol";

// ----------------------------------------------------------------------------
// BokkyPooBah's Red-Black Tree Library v1.0-pre-release-a - Contract for testing
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

// Unify the return value type to uint in order to always return a BigNumber.
contract TestBokkyPooBahsRedBlackTreeRaw {
    using BokkyPooBahsRedBlackTreeLibrary for BokkyPooBahsRedBlackTreeLibrary.Tree;

    BokkyPooBahsRedBlackTreeLibrary.Tree tree;
    bool reversed;
    mapping(uint40 => bool) public subtreeRemoved;

    event Log(string where, uint40 key, uint256 value);

    constructor() public {}

    function root() public view returns (uint256 _key) {
        _key = tree.root;
    }

    function first() public view returns (uint256 _key) {
        _key = tree.first();
    }

    function last() public view returns (uint256 _key) {
        _key = tree.last();
    }

    function next(uint40 key) public view returns (uint256 _key) {
        _key = tree.next(key);
    }

    function prev(uint40 key) public view returns (uint256 _key) {
        _key = tree.prev(key);
    }

    function exists(uint40 key) public view returns (bool _exists) {
        _exists = tree.exists(key);
    }

    function getNode(uint40 _key)
        public
        view
        returns (
            uint256 key,
            uint256 parent,
            uint256 left,
            uint256 right,
            bool red
        )
    {
        (key, parent, left, right, red) = tree.getNode(_key);
    }

    function getNodeUnsafe(uint40 _key)
        public
        view
        returns (
            uint256 key,
            uint256 parent,
            uint256 left,
            uint256 right,
            bool red
        )
    {
        BokkyPooBahsRedBlackTreeLibrary.Node memory node = tree.nodes[_key];
        (key, parent, left, right, red) = (
            key,
            node.parent,
            node.left,
            node.right,
            node.red
        );
    }

    function insert(uint40 _key) public {
        tree.insert(_key, 0, lessThan, aggregate);
        // emit Log("insert", _key, 0);
    }

    function insertBulk(uint40[] memory _keys) public {
        for (uint256 i = 0; i < _keys.length; i++) {
            insert(_keys[i]);
        }
    }

    function remove(uint40 _key) public {
        tree.remove(_key, aggregate);
        // emit Log("remove", _key, 0);
    }

    function removeLeft(uint40 _key) public {
        tree.removeLeft(_key, lessThan, aggregate, subtreeRemovedCallback);
    }

    function lessThan(
        BokkyPooBahsRedBlackTreeLibrary.Tree storage tree,
        uint40 key0,
        uint40 key1
    ) private view returns (bool) {
        require(key0 != 0, "lessThan key0 assert");
        require(key1 != 0, "lessThan key1 assert");
        return reversed ? key0 > key1 : key0 < key1;
    }

    function aggregate(uint40 key) private returns (bool stop) {
        require(key != 0, "aggregate assert");

        uint128 prevSum = tree.nodes[key].userData;
        uint128 sum = tree.nodes[tree.nodes[key].left].userData +
            tree.nodes[tree.nodes[key].right].userData +
            key;
        tree.nodes[key].userData = sum;
        stop = sum == prevSum;
    }

    function subtreeRemovedCallback(uint40 key) private {
        require(key != 0, "subtreeRemovedCallback assert");
        subtreeRemoved[key] = true;
    }

    function subtreeRemovedRecursive(uint40[] calldata keys)
        external
        view
        returns (bool[] memory result)
    {
        result = new bool[](keys.length);
        for (uint256 i = 0; i < keys.length; ++i) {
            uint40 key = keys[i];
            require(key != 0, "subtreeRemovedRecursive assert");

            bool res;
            while (key != 0) {
                if (subtreeRemoved[key]) {
                    res = true;
                    break;
                }
                key = tree.nodes[key].parent;
            }
            result[i] = res;
        }
    }

    function sums(uint40 key) external view returns (uint256) {
        return tree.nodes[key].userData;
    }

    function setReversed(bool reversedArg) public {
        reversed = reversedArg;
    }
}
