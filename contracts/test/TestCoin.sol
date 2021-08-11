// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "../FungibleToken.sol";

contract TestCoin is FungibleToken {

    uint256 public constant INITIAL_SUPPLY = 10000 * 1e18;

    constructor() FungibleToken("TestCoin", "TEST", "1") {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
