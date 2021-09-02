// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "./interfaces/IDubuDividend.sol";

contract DubuDividend is IDubuDividend {

    IBEP20 private constant DUBU = IBEP20(0x0000000000000000000000000000000000000000);
    IBEP20 private constant CAKE = IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);

    uint256 internal currentBalance = 0;
    mapping(address => uint256) internal cakeBalances;

    uint256 constant internal pointsMultiplier = 2**128;
    uint256 internal pointsPerShare = 0;
    mapping(address => int256) internal pointsCorrection;
    mapping(address => uint256) internal claimed;

    function updateBalance() internal {
        uint256 totalBalance = CAKE.balanceOf(address(this));
        require(totalBalance > 0);
        uint256 balance = DUBU.balanceOf(address(this));
        uint256 value = balance - currentBalance;
        if (value > 0) {
            pointsPerShare += value * pointsMultiplier / totalBalance;
            emit Distribute(msg.sender, value);
        }
        currentBalance = balance;
    }

    function claimedOf(address owner) override public view returns (uint256) {
        return claimed[owner];
    }

    function accumulativeOf(address owner) override public view returns (uint256) {
        uint256 _pointsPerShare = pointsPerShare;
        uint256 totalBalance = CAKE.balanceOf(address(this));
        require(totalBalance > 0);
        uint256 balance = DUBU.balanceOf(address(this));
        uint256 value = balance - currentBalance;
        if (value > 0) {
            _pointsPerShare += value * pointsMultiplier / totalBalance;
        }
        return uint256(int256(_pointsPerShare * cakeBalances[owner]) + pointsCorrection[owner]) / pointsMultiplier;
    }

    function claimableOf(address owner) override external view returns (uint256) {
        return accumulativeOf(owner) - claimed[owner];
    }

    function _accumulativeOf(address owner) internal view returns (uint256) {
        return uint256(int256(pointsPerShare * cakeBalances[owner]) + pointsCorrection[owner]) / pointsMultiplier;
    }

    function _claimableOf(address owner) internal view returns (uint256) {
        return _accumulativeOf(owner) - claimed[owner];
    }

    function claim() override external {
        updateBalance();
        uint256 claimable = _claimableOf(msg.sender);
        if (claimable > 0) {
            claimed[msg.sender] += claimable;
            emit Claim(msg.sender, claimable);
            DUBU.transfer(msg.sender, claimable);
            currentBalance -= claimable;
        }
    }

    function _enter(uint256 amount) internal {
        updateBalance();
        cakeBalances[msg.sender] += amount;
        pointsCorrection[msg.sender] -= int256(pointsPerShare * amount);
    }

    function _exit(uint256 amount) internal {
        updateBalance();
        cakeBalances[msg.sender] -= amount;
        pointsCorrection[msg.sender] += int256(pointsPerShare * amount);
    }
}
