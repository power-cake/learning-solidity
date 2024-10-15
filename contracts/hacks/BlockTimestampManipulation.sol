// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 区块链时间戳操作
 * @dev
    漏洞 block.timestamp 可以由矿工在以下约束下进行操纵
    1.it cannot be stamped with an earlier time than its parent
    2.it cannot be too far in the future
 */

/*
Roulette is a game where you can win all of the Ether in the contract
if you can submit a transaction at a specific timing.
A player needs to send 10 Ether and wins if the block.timestamp % 15 == 0.
*/

/*
1. Deploy Roulette with 10 Ether
2. Eve runs a powerful miner that can manipulate the block timestamp.
3. Eve sets the block.timestamp to a number in the future that is divisible by
   15 and finds the target block hash.
4. Eve's block is successfully included into the chain, Eve wins the
   Roulette game.
*/
contract Roulette {
    uint public pastBlockTime;

    constructor() payable {

    }

    function spin() external payable {
        require(msg.value == 10 ether);
//        only 1 transaction per block
        require(block.timestamp != pastBlockTime);

        pastBlockTime = block.timestamp;

        if (block.timestamp % 5 == 0) {
            (bool sent, ) = msg.sender.call{value: address(this).balance}("");
            require(sent, "Failed to send Ether");
        }
    }
}
// 预防技术
// 不要用做block.timestamp 熵和随机数等来源