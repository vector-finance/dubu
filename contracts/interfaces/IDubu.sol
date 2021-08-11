// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./IFungibleToken.sol";

interface IDubu is IFungibleToken {
    function mint(address to, uint256 amount) external;
}
