// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 多重委托调用
 * @dev   多重合约调用必须调用合约自身，可以把多重调用合约做成抽象合约，之后被调用合约继承 多重调用合约可能会给合约带来一定的漏洞
 */
contract MultiDelegateCall {
    error DelegateCallFail();

    function multiDelegateCall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results =  new bytes[](data.length);
        for (uint i = 0; i < data.length; i++) {
        (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegateCallFail();
            }
            results[i] = res;
        }
    }
}

contract TestMultiDelegatecall is MultiDelegateCall{
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint) {
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    mapping(address => uint) balanceOf;
// 当使用多重委托调用时是不安全的，用户可以多次mint for the price of msg.value
//  多重委托调用三次 [mint,mint,mint] mint 发送1个eth 但是会mint 三次 mint 3倍的代币
//   解决办法，可用不计算主币数量，或者禁用使用主币数量计算
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }

}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }

    function getfunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }

    function getMintData() external pure  returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
    }
}
