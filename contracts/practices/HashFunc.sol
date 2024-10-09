// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 哈希算法
 * @dev   哈希算法
 */
contract HashFunc {
    function hash(string  memory _text, uint _num, address _addr) external pure returns (bytes32){
        return keccak256(abi.encodePacked(_text,_num,_addr));
    }
//    不会对编码结果压缩，不同的输入内容，结果也不同
    function encode(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encode(text0, text1);
    }
//。  会对编码结果进行压缩，可能不同的输入内容，结果相同，容易出现哈希碰撞
    function encodePacked(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }

//  参数AAA,ABBB 与参数 AAAA，BBB的结果是一样的 需要更换为encode进行打包，也或者在两个字符串中间添加数字隔开避免出现这种情况
    function collision(string memory text0, string memory text1) external pure returns (bytes32){
        return keccak256(abi.encodePacked(text0,text1));
    }
}
