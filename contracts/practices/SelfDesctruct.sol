// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title  自毁
 * @dev   x
 */

//selfdestruct
//0 - delete contract
//1 - force send Ether to any address
contract Kill {

    constructor() payable{
    }

    function kill() external {
//        用msg.sender 而不用状态变量会减少gas消耗
        selfdestruct(payable(msg.sender));
//        suicide(payable(msg.sender));
    }
}

// 没有接收函数，依然可以接收eth，合约自毁时会强制发送以太币的
contract Helper {
    function getBalance() external returns (uint) {
        return address(this).balance;
    }

    function kill(Kill _kill) external {
        _kill.kill();
    }
}
