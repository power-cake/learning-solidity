// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Storage.sol";

contract Logic1 is Storage{

    function initialize(uint _x) external {
        rate = _x;
    }
}