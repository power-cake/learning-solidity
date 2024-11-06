// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 我们在上一讲已经学习了"选择器冲突"（Selector Clash），即合约存在两个选择器相同的函数，可能会造成严重后果。作为透明代理的替代方案，UUPS也能解决这一问题。
 *        UUPS（universal upgradeable proxy standard，通用可升级代理）将升级函数放在逻辑合约中。这样一来，如果有其它函数与升级函数存在“选择器冲突”，编译时就会报错
 * @dev   x
 */
contract UUPSProxy {
//    逻辑合约地址
    address public implementation;
    address public admin;
    string public words;

    constructor(address _implememtion) {
        address = msg.sender;
        implementation = _implementation;
    }

    fallback() external payable {
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success);
    }


}


contract UUPS1 {
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "old";
    }

    function upgrade(address newImplementation) external {
        require(msg.value == admin);
        implementation = newImplementation;
    }
}


/**
 * @dev 升级逻辑放在逻辑合约中
 */
contract UUPS2 {
    address public implementation;
    address public admin;
    string public words;

    function foo() external {
        words = "new";
    }

    function upgrade(address newImplementation) external {
        require(msg.value == admin);
        implementation = newImplementation;
    }
}