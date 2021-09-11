// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "./FungibleToken.sol";
import "./interfaces/IDubu.sol";
import "./interfaces/IDubuEmitter.sol";

contract Dubu is FungibleToken, IDubu {

    IDubuEmitter public emitter;
    
    constructor() FungibleToken("Dubu", "DUBU", "1") {
        emitter = IDubuEmitter(msg.sender);
    }

    modifier onlyEmitter {
        require(msg.sender == address(emitter));
        _;
    }

    function mint(address to, uint256 amount) onlyEmitter external override {
        _mint(to, amount);
    }
}
