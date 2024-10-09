// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title abi解码
 * @dev   对返回的数据进行解码
 */
contract AbiDecode {

    struct MyStruct {
        string name;
        uint[2] nums;
    }
    // 编码 结构体在remix里的输入方式 ["11",[1,2]]
    function encode(
        uint x,
        address addr,
        uint[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

//    解码前需要知道数据的格式
    function decode(bytes calldata data) external pure returns (
        uint x,
        address addr,
        uint[] memory arr,
        MyStruct memory myStruct
    ) {
        (x, addr, arr, myStruct) = abi.decode(data,(uint, address, uint[], MyStruct));
    }
}
