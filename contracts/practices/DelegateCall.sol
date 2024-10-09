// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//委托代理常用与代理模式
//委托调用与常规的合约调用不通，最终调用合约中的状态变量不会变化
//但是委托合约中的状态变量会变化
//A calls B, send 100 wei
//          B delegatecall C
//A------>B------------>C
//                    | msg.sender = A
//                    | msg.value = 100
//                    | execute code on B's state variable
//                    | use ETH in B

contract TestDelegateCall {
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) external payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract DelegateCall {
    uint public num;
    address public owner;
    uint public value;

    function setVars(address _test, uint _num) external payable{
//        (bool success, bytes memory data) = _test.delegatecall(abi.encodeWithSignature("setVars(uint256)",_num));
        (bool success,) = _test.delegatecall(abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num));
        require(success,"delegatecall failled");
    }
}
