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
contract TestBokkyPooBahsRedBlackTreeRaw {
    using BokkyPooBahsRedBlackTreeLibrary for BokkyPooBahsRedBlackTreeLibrary.Tree;

    BokkyPooBahsRedBlackTreeLibrary.Tree tree;

    event Log(string where, uint80 key, uint256 value);

    constructor() public {}

    function root() public view returns (uint80 _key) {
        _key = tree.root;
    }

    function first() public view returns (uint80 _key) {
        _key = tree.first();
    }

    function last() public view returns (uint80 _key) {
        _key = tree.last();
    }

    function next(uint80 key) public view returns (uint80 _key) {
        _key = tree.next(key);
    }

    function prev(uint80 key) public view returns (uint80 _key) {
        _key = tree.prev(key);
    }

    function exists(uint80 key) public view returns (bool _exists) {
        _exists = tree.exists(key);
    }

    function getNode(uint80 _key)
        public
        view
        returns (
            uint80 key,
            uint80 parent,
            uint80 left,
            uint80 right,
            bool red
        )
    {
        (key, parent, left, right, red) = tree.getNode(_key);
    }

    function getNodeUnsafe(uint80 _key)
        public
        view
        returns (
            uint80 key,
            uint80 parent,
            uint80 left,
            uint80 right,
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

    function insert(uint80 _key) public {
        tree.insert(_key, lessThan, aggregate);
        // emit Log("insert", _key, 0);
    }

    function insertBulk(uint80[] memory _keys) public {
        for (uint256 i = 0; i < _keys.length; i++) {
            insert(_keys[i]);
        }
    }

    function remove(uint80 _key) public {
        tree.remove(_key, aggregate);
        // emit Log("remove", _key, 0);
    }

    function removeLeft(uint80 _key) public {
        tree.removeLeft(_key, lessThan, aggregate);
    }

    function lessThan(uint80 key0, uint80 key1) private pure returns (bool) {
        return key0 < key1;
    }

    function aggregate(uint80 key) private returns (bool) {
        return true;
    }
}
