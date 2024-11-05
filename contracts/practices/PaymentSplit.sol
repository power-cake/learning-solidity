// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 该合约简化来自@openzeppelin 版本低于v5.0 ,v5.0 +之后移除了该合约
 * @dev   分账合约 这个合约会把收到的ETH按事先定好的份额分给几个账户。收到ETH会存在分账合约中，需要每个受益人调用release()函数来领取
 */
contract PaymentSplit {

    event PayeeAdded(address account, uint shares);
    event PaymentReleased(address to, uint amount);
    event PaymentReceived(address from, uint amount);
//    总份额
    uint public totalShares;
//    总支付
    uint public totalReleased;
//    每个受益人的份额
    mapping(address => uint) public shares;
//    支付给每受益人的金额
    mapping(address => uint) public released;
//    受益人数组
    address[] payees;

    constructor(address[] memory _payees, uint[] memory _shares) {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length >0, "PaymentSplitter: no payees");
        
        for (uint i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

//    external

//    回调函数.收到ETH释放事件
    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

//    public

    /**
     * @dev 为有效受益人地址分账, 相应的eth直接发送到受益人的地址,任何人都可以出发这个函数,但钱会打到account账户中
     */
    function release(address payable _account) public virtual{
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");
        uint payment = releaseable(_account);
        require(payment != 0, "PaymentSplitter: account is not due payment");

        totalReleased += payment;
        released[_account] += payment;
        _account.transfer(payment);

        emit PaymentReceived(_account, payment);
    }

    /**
     * @dev 计算一个用户可以领取的eth数量
     */
    function releaseable(address _account) public view returns (uint) {
        uint totalReceived = address(this).balance + totalReleased;
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    /**
     * @dev
     */
    function pendingPayment(
        address _account,
        uint _totalReceived,
        uint _alreadyReleased
    )
        public
        view
        returns (uint)
    {
        return (_totalReceived * shares[_account]) / totalShares - _alreadyReleased;
    }
    
    
//    internal
//    private

    function _addPayee(address _account, uint _shares) private {
        require(_account != address(0), "PaymentSplitter: account is the zero address");
        require(_shares > 0, "PaymentSplitter: shares are 0");
        require(shares[_account] == 0, "PaymentSplitter: account already has shares");

        payees.push(_account);
        shares[_account] = _shares;
        totalShares += _shares;

        emit PayeeAdded(_account, _shares);
    }

}
