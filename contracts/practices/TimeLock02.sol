// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 任何人可以调用的时间锁合约
 * @notice 任何人都可以使用这个时间锁合约
 * @notice 将交易放入时间锁合约中，在特定时间后才可以执行
 * @notice 将交易放进时间锁合约中，未执行则可以从时间锁合约中删除
 */
contract TimeLock02 {

    error AlreadyQueuedError(address caller, bytes32 txId);
    error NotExistQueuedError(address caller, bytes32 txId);
    error ExecuteError(bytes32 txId);
    error TimestampNotInRangeError();

    event Queue(
        bytes32 txId,
        address indexed _target,
        uint256 _value,
        bytes _data,
        uint256 _timestamp
    );

    event Execute(
        bytes32 txId,
        address indexed _target,
        uint256 _value,
        bytes _data,
        uint256 _timestamp
    );

    event Cancel(address caller, bytes32 txId);

    address public owner;
    uint public MIN_DELAY = 60;
    uint public MAX_DELAY = 600;

    mapping(address => mapping(bytes32 => bool)) public queued;

    constructor() {
        owner = msg.sender;
    }

    function getTxId(
        address _target,
        uint256 _value,
        bytes calldata _data,
        uint256 _timestamp
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _data, _timestamp));
    }

    function queue(
        address _target,
        uint _value,
        bytes calldata _data,
        uint _timestamp
    ) external {
        if (_timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRangeError();
        }
        bytes32 txId = getTxId(_target, _value, _data, _timestamp);
        if (queued[msg.sender][txId]) {
            revert AlreadyQueuedError(msg.sender, txId);
        }

        queued[msg.sender][txId] = true;

        emit Queue(txId, _target, _value, _data, _timestamp);
    }

    function execute(
        address _target,
        uint _value,
        bytes calldata _data,
        uint _timestamp
    ) external payable returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _data, _timestamp);
        if (!queued[msg.sender][txId]) {
            revert NotExistQueuedError(msg.sender, txId);
        }

        queued[msg.sender][txId] = false;

        (bool ok, bytes memory data) = _target.call{value: _value}(_data);
        if (!ok) {
            revert ExecuteError(txId);
        }

        emit Queue(txId, _target, _value, _data, _timestamp);
        return data;
    }

    function cancel(bytes32 _txId) external {
        if (!queued[msg.sender][_txId]) {
            revert NotExistQueuedError(msg.sender,_txId);
        }
        queued[msg.sender][_txId] = false;
        emit Cancel(msg.sender, _txId);
    }

    function getTimesampt() external view  returns (uint) {
        return block.timestamp;
    }

}

contract TestTimeLock02 {
    address public timeLock;

    error UnautorizedError(address caller);

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function func1() external view returns (uint, uint) {
        if (msg.sender != timeLock) {
            revert UnautorizedError(msg.sender);
        }

        return (1, block.timestamp);
    }

}
