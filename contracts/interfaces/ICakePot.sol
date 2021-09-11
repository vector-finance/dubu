// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./IDubuDividend.sol";

interface ICakePot is IDubuDividend {

    event Start(uint256 indexed season);
    event End(uint256 indexed season);
    event Enter(uint256 indexed season, address indexed who, uint256 amount);
    event Exit(uint256 indexed season, address indexed who, uint256 amount);
    
    function currentSeason() external view returns (uint256);
    
    function userCounts(uint256 season) external view returns (uint256);
    function amounts(uint256 season, address who) external view returns (uint256);
    function totalAmounts(uint256 season) external view returns (uint256);
    function weights(uint256 season, address who) external view returns (uint256);
    function totalWeights(uint256 season) external view returns (uint256);
    
    function ssrs(uint256 season, uint256 index) external view returns (address);
    function srs(uint256 season, uint256 index) external view returns (address);
    function rs(uint256 season, uint256 index) external view returns (address);
    
    function checkEnd() external view returns (bool);
    function enter(uint256 amount) external;
    function end() external;
    function exit(uint256 season) external;
}
