// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 写入任意插槽
 * @dev   Solidity 存储就像一个长度为 2^256 的数组。数组中的每个槽可以存储 32 个字节。
 *        状态变量定义哪些插槽将用于存储数据， 但是使用汇编，您可以写入任何插槽
 */
contract Storage {

    struct MyStruct {
        uint value;
    }

//    struct stored at slot 0
    MyStruct public s0 = MyStruct(123);
//    struct stored at slot 1
    MyStruct public s1 = MyStruct(456);
//    struct stored at slot 2
    MyStruct public s2 = MyStruct(789);

//    指定插槽位置返回储存
    function _get(uint i) internal pure returns (MyStruct storage s) {
//        get struct stored at slot i
        assembly {
            s.slot := i
        }
    }

    function get(uint i) external view returns (uint) {
//         get value inside MyStruct stored at slot i
        return _get(i).value;
    }

    /*
    我们可以将数据保存到任何插槽，包括通常不可访问的插槽999。

    set(999) = 888
    */

    function set(uint i, uint x) external {
        // 将MyStruct的值设置为x并将其存储在插槽中
        _get(i).value = x;
    }

}
