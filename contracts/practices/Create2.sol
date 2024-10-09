// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title create2方法
 * @dev   x
 */
contract DeployWithCreate2 {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

contract Create2Factory {
    event Deploy(address addr);
//    部署合约
    function deploy(uint _salt) external {
        DeployWithCreate2 _contract = new DeployWithCreate2{salt: bytes32(_salt)}(msg.sender);
        emit Deploy(address(_contract));
    }

//   计算出合约的地址
    function getAddress(bytes memory byteCode, uint _salt) external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(byteCode)
            )
        );
        return address(uint160(uint(hash)));
    }

//    获取合约码
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}
