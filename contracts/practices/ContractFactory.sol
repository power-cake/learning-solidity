// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

 /**
 * @title 合约工厂
 * @dev   合约工厂
 */


contract Account {
    address public bank;
    address public owner;

    constructor(address _owner) payable {
        bank = msg.sender;
        owner = _owner;
    }
}

contract ContractFactory {
    Account[] public accounts;

    function createAccount(address _owner) external {
        Account account = new Account{value: 123}(_owner);
        accounts.push(account);
    }
}
