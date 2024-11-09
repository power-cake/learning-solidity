// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
/**
 * @title 详细见 https://www.wtf.academy/docs/solidity-103/EIP712/
 * @dev   链上验证
 */
//EIP712Domain: [
//    { name: "name", type: "string" },
//    { name: "version", type: "string" },
//    { name: "chainId", type: "uint256" },
//    { name: "verifyingContract", type: "address" },
//]
//const domain = {
//    name: "EIP712Storage",
//    version: "1",
//    chainId: "1",
//    verifyingContract: "0xf8e81D47203A594245E36C48e151709F0C19fBe8",
//};
//const types = {
//    Storage: [
//        { name: "spender", type: "address" },
//        { name: "number", type: "uint256" },
//    ],
//};
//const message = {
//    spender: "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
//    number: "100",
//};
contract EIP712Storage {
    using ECDSA for bytes32;

    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712domain(string name,string version,uint256 chainId,address verifyContract)");
    bytes32 private constant STORAGE_TYPEHASH = keccak256("Storage(address spender,uint256 number)");
    bytes32 private DOMAIN_SEPARATOR;
    uint private number;
    address public owner;

    constructor() {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH, //type hash [function]
            keccak256(bytes("EIP712Storage")), // name
            keccak256(bytes("1")), // version
            block.chainid, // chain id
            address(this) // verify contract address
        ));
        owner = msg.sender;
    }

    function permitStore(uint256 _num, bytes memory _signature) public {
        require(_signature.length == 65, "invalid signature length");
//        前32 bytes 储存签名的长度 (动态数组储存规则)
//        add(sig,32) = sig的签名 + 32
//        等效为略过signature的前32 bytes
//        mload(p) 载入从内存地址p起始的接下来32 bytes数据
        bytes32 r;
        bytes32 s;
        uint8 v;
//        目前只能用assembly (内联汇编) 来从签名中获得r,s,v的值
        assembly {
//            读取数据之后的32 bytes 数据
            r := mload(add(_signature,0x20))
//            读取数据之后的32 bytes 数据
            s := mload(add(_signature,0x40))
//            读取最后一个byte
            v := byte(0, mload(add(_signature, 0x60)))
        }
//        获取签名消息hash
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(STORAGE_TYPEHASH, msg.sender, _num))
        ));

        address signer = digest.recover(v, r, s);
        require(signer == owner, "EIP712Storage: Invalid signature");

        number = _num;
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}
