// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Storage.sol";

contract Logic2 is Storage{

    function initialize(uint _x) external {
        rate = _x;
    }

    function setY(uint _y) external {
        y = _y;
    }


}