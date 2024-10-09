// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 函数选择器
 * @dev   x
 */
contract FunctionSelector {
    function getSelector(string calldata _func) external pure  returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
        
    }
}
