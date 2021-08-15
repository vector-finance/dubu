// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IPriceCalculator {
    function pricesInUSD(address[] memory assets) external view returns (uint[] memory);
    function valueOfAsset(address asset, uint amount) external view returns (uint valueInBNB, uint valueInUSD);
}