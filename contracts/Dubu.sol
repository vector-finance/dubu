// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./FungibleToken.sol";
import "./interfaces/IDubu.sol";
import "./interfaces/IFarmFactory.sol";

contract Dubu is FungibleToken, IDubu {

    IFarmFactory public factory;
    
    constructor() FungibleToken("Dubu", "DUBU", "1") {
        factory = IFarmFactory(msg.sender);
    }

    modifier onlyFactory {
        require(msg.sender == address(factory));
        _;
    }

    function mint(address to, uint256 amount) onlyFactory external override {
        _mint(to, amount);
    }
}
