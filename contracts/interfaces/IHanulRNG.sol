// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IHanulRNG {
    function generateRandomNumber(uint256 seed, address sender) external returns (uint256);
}
