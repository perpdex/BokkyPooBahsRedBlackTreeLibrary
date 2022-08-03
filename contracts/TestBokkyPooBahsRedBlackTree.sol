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
    mapping(uint80 => uint) values;

    event Log(string where, uint80 key, uint value);

    constructor() public {
    }
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
    function getNode(uint80 _key) public view returns (uint80 key, uint80 parent, uint80 left, uint80 right, bool red, uint value) {
        if (tree.exists(_key)) {
            (key, parent, left, right, red, ) = tree.getNode(_key);
            value = values[_key];
        }
    }

    function insert(uint80 _key, uint _value) public {
        tree.insert(_key, lessThan, aggregate);
        values[_key] = _value;
        emit Log("insert", _key, _value);
    }
    function remove(uint80 _key) public {
        tree.remove(_key, aggregate);
        emit Log("remove", _key, values[_key]);
        delete values[_key];
    }

    function lessThan(uint80 key0, uint80 key1) private pure returns (bool) {
        return key0 < key1;
    }

    function aggregate(uint80 key) private returns (bool) {
        return true;
    }
}
