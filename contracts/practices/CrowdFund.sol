// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title 众筹合约
 * @dev   x
 */
contract CrowdFund {

//    活动
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startAt;
        uint endAt;
        bool claimed;
    }

    event Launch(uint id, address indexed creator, uint goal, uint startAt, uint endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Retract(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id, address caller, uint amount);
    event Refund(uint indexed id, address indexed caller, uint amount);

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

//    必须当前时间后90天内结束
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt > _startAt, "end at <= start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            startAt: _startAt,
            endAt: _endAt,
            pledged: 0,
            claimed: false
        });

        emit Launch(count, msg.sender, _goal, _startAt, _endAt);
    }
    
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "campaign canceled");
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit Pledge(_id, msg.sender, _amount);
    }

    function retract(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledged -= _amount;

        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);

        emit Retract(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.creator, "not creator");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
//        用msg.sender 而不用去状态变量中读取是为了节省gas
        token.transfer(msg.sender, campaign.pledged);

        emit Claim(_id, msg.sender, campaign.pledged);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged > goal");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id, msg.sender, bal);
    }
}
