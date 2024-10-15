// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 抢先交易
 * @dev
    漏洞：
    交易需要一段时间才能被挖掘出来，攻击者可以监视交易池并发送交易，将其包含在原始交易之前的区块中
    这种机制可以被滥用来重新排序交易，以使攻击者获得优势。
 */

/*
Alice creates a guessing game.
You win 10 ether if you can find the correct string that hashes to the target
hash. Let's see how this contract is vulnerable to front running.
*/

/*
1. Alice deploys FindThisHash with 10 Ether.
2. Bob finds the correct string that will hash to the target hash. ("Ethereum")
3. Bob calls solve("Ethereum") with gas price set to 15 gwei.
4. Eve is watching the transaction pool for the answer to be submitted.
5. Eve sees Bob's answer and calls solve("Ethereum") with a higher gas price
   than Bob (100 gwei).
6. Eve's transaction was mined before Bob's transaction.
   Eve won the reward of 10 ether.

What happened?
Transactions take some time before they are mined.
Transactions not yet mined are put in the transaction pool.
Transactions with higher gas price are typically mined first.
An attacker can get the answer from the transaction pool, send a transaction
with a higher gas price so that their transaction will be included in a block
before the original.
*/
contract findThisHash {
    bytes32 public constant hash = 0x564ccaf7594d66b1eaaea24fe01f0585bf52ee70852af4eac0cc4b04711cd0e2;

    constructor() payable {
    }

    function solve(string memory solution) public {
        require(hash == keccak256(abi.encodePacked(solution)),"Incorrect");

        (bool sent, ) = msg.sender.call{value: 1 ether}("");
        require(sent, "Failed to sent Ether");
    }

//    解决方案
//use commit-reveal scheme  先提交，等块确定之后在解密
//use submarine send

}
