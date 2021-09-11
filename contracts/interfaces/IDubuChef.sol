// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./IDubuDividend.sol";

interface IDubuChef is IDubuDividend {

    event Enter(address indexed who, uint256 amount);
    event Exit(address indexed who, uint256 amount);
    
    function enter(uint256 amount) external;
    function exit(uint256 amount) external;
}
