// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract TestCall {
    string public message;
    uint public x;

    event Log(string message);

    fallback() external payable {
        emit Log("fallback was called");
    }

    function foo(string memory  _message, uint _x)external payable returns (bool, uint) {
        message = _message;
        x = _x;
        return (true, 999);
    }
}


contract Call {
    bytes public data;
//    合约间的低级调用
    function callFoo(address _test) external payable {
        (bool success, bytes memory _data) =  _test.call{value:1234, gas: 5000}(abi.encodeWithSignature("foo(string,uint256)","call foo",123));
        require(success,"call failed");
        data = _data;
    }

//    调用不存在的合约方法，会调用回退函数
    function callDoesNotExit(address _test) external {
        (bool success, ) = _test.call(abi.encodeWithSignature("doesNotExist()"));
        require(success,"call failed");
    }
}