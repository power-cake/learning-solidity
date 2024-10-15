// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title x
 * @dev   x
 */
contract StakingRewards {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;

    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public reward;

    uint private _totalSupply;
    mapping(address => uint) private _balances;

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0 ) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored +
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    function earned(address account) public view returns (uint) {
        return (_balances[account] * (rewardPerToken() -
                userRewardPerTokenPaid[account])) / 1e18 + reward[account];
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        reward[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this),_amount);
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender , _amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint rewards = reward[msg.sender];
        reward[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, rewards);
    }
}
