// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "./interfaces/IDubuEmitter.sol";
import "./interfaces/IDubuDividend.sol";

contract DubuDividend is IDubuDividend {

    IDubuEmitter private constant DUBU_EMITTER = IDubuEmitter(0xDDb921d4F0264c10884D652E3aB9704F8189DAf4);
    IBEP20 private constant DUBU = IBEP20(0x972543fe8BeC404AB14e0c38e942032297f44B2A);

    uint256 private immutable pid;

    constructor() {
        pid = DUBU_EMITTER.poolCount();
    }

    uint256 internal currentBalance = 0;
    uint256 internal totalTokenBalance = 0;
    mapping(address => uint256) internal tokenBalances;

    uint256 constant internal pointsMultiplier = 2**128;
    uint256 internal pointsPerShare = 0;
    mapping(address => int256) internal pointsCorrection;
    mapping(address => uint256) internal claimed;

    function updateBalance() internal {
        if (totalTokenBalance > 0) {
            DUBU_EMITTER.updatePool(pid);
            uint256 balance = DUBU.balanceOf(address(this));
            uint256 value = balance - currentBalance;
            if (value > 0) {
                pointsPerShare += value * pointsMultiplier / totalTokenBalance;
                emit Distribute(msg.sender, value);
            }
            currentBalance = balance;
        }
    }

    function claimedOf(address owner) override public view returns (uint256) {
        return claimed[owner];
    }

    function accumulativeOf(address owner) override public view returns (uint256) {
        uint256 _pointsPerShare = pointsPerShare;
        if (totalTokenBalance > 0) {
            uint256 balance = DUBU_EMITTER.pendingToken(pid) + DUBU.balanceOf(address(this));
            uint256 value = balance - currentBalance;
            if (value > 0) {
                _pointsPerShare += value * pointsMultiplier / totalTokenBalance;
            }
            return uint256(int256(_pointsPerShare * tokenBalances[owner]) + pointsCorrection[owner]) / pointsMultiplier;
        }
        return 0;
    }

    function claimableOf(address owner) override external view returns (uint256) {
        return accumulativeOf(owner) - claimed[owner];
    }

    function _accumulativeOf(address owner) internal view returns (uint256) {
        return uint256(int256(pointsPerShare * tokenBalances[owner]) + pointsCorrection[owner]) / pointsMultiplier;
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
        totalTokenBalance += amount;
        tokenBalances[msg.sender] += amount;
        pointsCorrection[msg.sender] -= int256(pointsPerShare * amount);
    }

    function _exit(uint256 amount) internal {
        updateBalance();
        totalTokenBalance -= amount;
        tokenBalances[msg.sender] -= amount;
        pointsCorrection[msg.sender] += int256(pointsPerShare * amount);
    }
}
