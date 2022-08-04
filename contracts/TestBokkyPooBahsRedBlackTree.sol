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
contract TestBokkyPooBahsRedBlackTree {
    using BokkyPooBahsRedBlackTreeLibrary for BokkyPooBahsRedBlackTreeLibrary.Tree;

    BokkyPooBahsRedBlackTreeLibrary.Tree tree;
    mapping(uint40 => uint256) values;

    event Log(string where, uint40 key, uint256 value);

    constructor() public {}

    function root() public view returns (uint40 _key) {
        _key = tree.root;
    }

    function first() public view returns (uint40 _key) {
        _key = tree.first();
    }

    function last() public view returns (uint40 _key) {
        _key = tree.last();
    }

    function next(uint40 key) public view returns (uint40 _key) {
        _key = tree.next(key);
    }

    function prev(uint40 key) public view returns (uint40 _key) {
        _key = tree.prev(key);
    }

    function exists(uint40 key) public view returns (bool _exists) {
        _exists = tree.exists(key);
    }

    function getNode(uint40 _key)
        public
        view
        returns (
            uint40 key,
            uint40 parent,
            uint40 left,
            uint40 right,
            bool red,
            uint256 value
        )
    {
        if (tree.exists(_key)) {
            (key, parent, left, right, red) = tree.getNode(_key);
            value = values[_key];
        }
    }

    function insert(uint40 _key, uint256 _value) public {
        tree.insert(_key, lessThan, aggregate);
        values[_key] = _value;
        emit Log("insert", _key, _value);
    }

    function remove(uint40 _key) public {
        tree.remove(_key, aggregate);
        emit Log("remove", _key, values[_key]);
        delete values[_key];
    }

    function lessThan(uint40 key0, uint40 key1) private pure returns (bool) {
        return key0 < key1;
    }

    function aggregate(uint40 key) private returns (bool) {
        return true;
    }
}
