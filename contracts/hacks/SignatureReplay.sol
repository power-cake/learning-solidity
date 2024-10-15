// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


 /**
 * @title 签名重播
 * @dev   在链下签署消息并签订在执行功能之前要求签名的合约是一种有用的技术
 */
//漏洞
// 同一个签名可以多次使用来执行一个功能，如果签名者的意图说批准一个交易，那么这可能会造成危害

contract MultiSigWallet {

    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address[2] public owners;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {

    }

    function transfer(address _to, uint _amount, bytes[2] memory _sigs) external {
        bytes32 txHash = getTxHash(_to, _amount);
        require(_checkSigs(_sigs, txHash), "invalid sig");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getTxHash(address _to, uint _amount) public view returns (bytes32) {
        return keccak256(abi.encodePacked(_to,_amount));
    }

    function _checkSigs(bytes[2] memory sigs, bytes32 _txHash) private view returns (bool) {
        bytes32 ethSigedHash = _txHash.toEthSignedMessageHash();
        for (uint i = 0; i < sigs.length; i++) {
            address signer = ethSigedHash.recover(sigs[i]);
            bool valid = signer == owners[i];
            if (!valid) {
                return false;
            }
        }
        return true;
    }
}
// 预防技术
//nonce 使用合约地址签署消息

contract MutiSigWallet2 {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address[2] public owners;
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owners) payable {
        owners = _owners;
    }

    function deposit() external payable {}

    function transfer(
        address _to,
        uint _amount,
        uint _nonce,
        bytes[2] memory _sigs
    ) external {
        bytes32 txHash = getTxHash(_to, _amount, _nonce);
//        记录
        require(!executed[txHash], "tx executed");
        require(_checkSigs(_sigs, txHash), "invalid sig");

        executed[txHash] = true;

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function getTxHash(
        address _to,
        uint _amount,
        uint _nonce
    ) public view returns (bytes32) {
//        使用nonce 并锁定当前合约地址
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }

    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash)
    private
    view
    returns (bool)
    {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);
            bool valid = signer == owners[i];

            if (!valid) {
                return false;
            }
        }

        return true;
    }
}