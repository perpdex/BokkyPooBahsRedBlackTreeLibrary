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

    struct Data {
        BokkyPooBahsRedBlackTreeLibrary.Tree tree;
        bool reversed;
        mapping(uint40 => bool) subtreeRemoved;
    }

    Data data;

    event Log(string where, uint40 key, uint256 value);

    constructor() public {}

    function root() public view returns (uint256 _key) {
        _key = data.tree.root;
    }

    function first() public view returns (uint256 _key) {
        _key = data.tree.first();
    }

    function last() public view returns (uint256 _key) {
        _key = data.tree.last();
    }

    function next(uint40 key) public view returns (uint256 _key) {
        _key = data.tree.next(key);
    }

    function prev(uint40 key) public view returns (uint256 _key) {
        _key = data.tree.prev(key);
    }

    function exists(uint40 key) public view returns (bool _exists) {
        _exists = data.tree.exists(key);
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
        (key, parent, left, right, red) = data.tree.getNode(_key);
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
        BokkyPooBahsRedBlackTreeLibrary.Node memory node = data.tree.nodes[
            _key
        ];
        (key, parent, left, right, red) = (
            key,
            node.parent,
            node.left,
            node.right,
            node.red
        );
    }

    function insert(uint40 _key) public {
        data.tree.insert(_key, 0, lessThan, aggregate, getSlot(data));
        // emit Log("insert", _key, 0);
    }

    function insertBulk(uint40[] memory _keys) public {
        for (uint256 i = 0; i < _keys.length; i++) {
            insert(_keys[i]);
        }
    }

    function remove(uint40 _key) public {
        data.tree.remove(_key, aggregate, getSlot(data));
        // emit Log("remove", _key, 0);
    }

    function removeLeft(uint40 _key) public {
        data.tree.removeLeft(
            _key,
            lessThan,
            aggregate,
            subtreeRemovedCallback,
            getSlot(data)
        );
    }

    function lessThan(
        uint40 key0,
        uint40 key1,
        uint256 dataSlot
    ) private view returns (bool) {
        Data storage d = getData(dataSlot);

        require(key0 != 0, "lessThan key0 assert");
        require(key1 != 0, "lessThan key1 assert");
        return d.reversed ? key0 > key1 : key0 < key1;
    }

    function aggregate(uint40 key, uint256 dataSlot)
        private
        returns (bool stop)
    {
        Data storage d = getData(dataSlot);

        require(key != 0, "aggregate assert");

        uint128 prevSum = d.tree.nodes[key].userData;
        uint128 sum = d.tree.nodes[d.tree.nodes[key].left].userData +
            d.tree.nodes[d.tree.nodes[key].right].userData +
            key;
        d.tree.nodes[key].userData = sum;
        stop = sum == prevSum;
    }

    function subtreeRemovedCallback(uint40 key, uint256 dataSlot) private {
        Data storage d = getData(dataSlot);

        require(key != 0, "subtreeRemovedCallback assert");
        d.subtreeRemoved[key] = true;
    }

    function subtreeRemoved(uint40 key) external view returns (bool) {
        return data.subtreeRemoved[key];
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
                if (data.subtreeRemoved[key]) {
                    res = true;
                    break;
                }
                key = data.tree.nodes[key].parent;
            }
            result[i] = res;
        }
    }

    function sums(uint40 key) external view returns (uint256) {
        return data.tree.nodes[key].userData;
    }

    function setReversed(bool reversedArg) public {
        data.reversed = reversedArg;
    }

    function getSlot(Data storage d) private pure returns (uint256 slot) {
        assembly {
            slot := d.slot
        }
    }

    function getData(uint256 slot) private pure returns (Data storage d) {
        assembly {
            d.slot := slot
        }
    }
}
