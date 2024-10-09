// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title x
 * @dev   x
 */
library IterableMapping02{

    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage _map, address _key) public view returns (uint) {
        return _map.values[_key];
    }

    function getKeyAtIndex(Map storage _map, uint _index) public view returns (address) {
        return _map.keys[_index];
    }

    function size(Map storage _map) public view returns (uint) {
        return _map.keys.length;
    }

    function set(
        Map storage _map,
        address _key,
        uint val
    ) public {
        if (_map.inserted[_key]) {
            _map.values[_key] = val;
        } else {
            _map.inserted[_key] = true;
            _map.values[_key] = val;
            _map.indexOf[_key] = _map.keys.length;
            _map.keys.push(_key);
        }
    }

    function remove(Map storage _map, address _key) public {
        if (!_map.inserted[_key]) {
            return ;
        }

        delete _map.inserted[_key];
        delete _map.values[_key];

//        最后一个填补当前删除元素的位置
        uint index = _map.indexOf[_key];
        uint lastIndex = _map.keys.length - 1;
        address lastKey = _map.keys[lastIndex];

        _map.indexOf[_key] = index;
        delete _map.indexOf[lastKey];

        _map.keys[index] = lastKey;
        _map.keys.pop();
    }
}

contract TestIterableMap {
    using IterableMapping02 for IterableMapping02.Map;

    IterableMapping02.Map private map;

    function testIterableMap() public {
        map.set(address(0), 0);
        map.set(address(1), 100);
        map.set(address(2), 200);
        map.set(address(3), 300);

        for (uint i = 0; i < map.size(); i++) {
            address key = map.getKeyAtIndex(i);
            assert(map.get(key) == i * 100);
        }

        map.remove(address(1));

//        keys = [address(0), addres(3), address(2)]
        assert(map.size() == 3);
        assert(map.getKeyAtIndex(0) == address(0));
        assert(map.getKeyAtIndex(1) == address(3));
        assert(map.getKeyAtIndex(2) == address(2));
    }
}
