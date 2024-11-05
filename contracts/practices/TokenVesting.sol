// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title 这一讲，我们将介绍代币归属条款，并写一个线性释放ERC20代币的合约。代码由OpenZeppelin的VestingWallet合约简化而来。
 * @dev   在传统金融领域，一些公司会向员工和管理层提供股权。但大量股权同时释放会在短期产生抛售压力，拖累股价。
 *        因此，公司通常会引入一个归属期来延迟承诺资产的所有权。同样的，在区块链领域，Web3初创公司会给团队分配代币，
 *        同时也会将代币低价出售给风投和私募。如果他们把这些低成本的代币同时提到交易所变现，币价将被砸穿，散户直接成为接盘侠
 */
contract TokenVesting {
    
    event ERC20Released(address indexed token, uint amount);

//  代币地址->释放数量的映射，记录已经释放的代币
    mapping(address => uint) public erc20Released;
//   受益人地址
    address public immutable beneficiary;
//    起始时间戳
    uint public immutable start;
//    归属期
    uint public immutable duration;


    constructor(address beneficiaryAddress, uint durationSeconds) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        start = block.timestamp;
        duration = durationSeconds;
    }

    /**
     * @dev 受益人提取已释放的代币
     */
    function release(address token) public {
//        计算可提取的代币数量
        uint releasable = vestedAmount(token,uint256(block.timestamp)) - erc20Released[token];
    }

    function vestedAmount(address token, uint timestamp) public view returns (uint) {
//        计算出合约里收到了多少代币 (余额+已经提取的)
        uint totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
//        根据公式计算出已经释放的量
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        }else {
            return totalAllocation * (timestamp - start) / duration;
        }
    }
}
