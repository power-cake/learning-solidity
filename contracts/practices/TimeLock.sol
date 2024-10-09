// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 时间锁合约
 * @dev   x
 */
contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestamoNotPassedError(uint blockTimestamp, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiredAt);
    error TxFailedError(bytes32 txId);

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );

    event Cancel(bytes32 txId);


    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 1000;
    uint public constant GRACE_PERIOD = 1000;


    address public owner;
    mapping(bytes32 => bool) public queued;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getTxId(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) public pure returns (bytes32 txId) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    receive() external payable {}

//    添加到交易队列中
    function queue(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    )
    external
    onlyOwner
    {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }
//        check timestamp
        if (_timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        queued[txId] = true;
        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute(
        address _target,
        uint _value,
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (!queued[txId]) {
            revert NotQueuedError(txId);
        }
        if (block.timestamp < _timestamp) {
            revert TimestamoNotPassedError(block.timestamp, _timestamp);
        }

        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }
        queued[txId] = false;

        bytes memory data;
        if (bytes(_func).length >0) {
            data = abi.encodePacked(
               bytes4(keccak256(bytes(_func))), data
            );
        }else {
            data = _data;
        }

        (bool ok, bytes memory result) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError(txId);
        }

        emit Execute(txId, _target, _value, _func, _data, _timestamp);

        return result;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!queued[_txId]) {
            revert NotQueuedError(_txId);
        }
        queued[_txId] = false;

        emit Cancel(_txId);
    }
}

contract TestTimeLock {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function test() external {

    }
}