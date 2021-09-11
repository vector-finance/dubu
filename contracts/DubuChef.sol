// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "./interfaces/IDubuChef.sol";
import "./interfaces/IHanulRNG.sol";
import "./interfaces/IMasterChef.sol";
import "./DubuDividend.sol";

contract DubuChef is Ownable, IDubuChef, DubuDividend {

    constructor() DubuDividend() {}

    function enter(uint256 amount) override external {
        DUBU.transferFrom(msg.sender, address(this), amount);
        _enter(amount);
        emit Enter(msg.sender, amount);
    }

    function exit(uint256 amount) override external {
        _exit(amount);
        DUBU.transfer(msg.sender, amount);
        emit Exit(msg.sender, amount);
    }
}
