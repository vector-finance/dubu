// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IDubuEmitter.sol";
import "./Dubu.sol";

contract DubuEmitter is Ownable, IDubuEmitter {
    uint256 private constant PRECISION = 1e20;
    
    struct PoolInfo {
        address to;
        uint256 allocPoint;
        uint256 lastEmitBlock;
    }

    IDubu public immutable override dubu;
    uint256 public immutable override emitPerBlock;
    uint256 public immutable override startBlock;

    PoolInfo[] public override poolInfo;
    uint256 public override totalAllocPoint;

    constructor(
        uint256 _emitPerBlock,
        uint256 _startBlock
    ) {
        dubu = new Dubu();
        emitPerBlock = _emitPerBlock;
        startBlock = _startBlock;
    }

    function poolCount() external view override returns (uint256) {
        return poolInfo.length;
    }

    function pendingToken(uint256 pid) external view override returns (uint256) {
        PoolInfo memory pool = poolInfo[pid];
        uint256 _lastEmitBlock = pool.lastEmitBlock;
        if (block.number > _lastEmitBlock && pool.allocPoint != 0) {
            return (block.number - _lastEmitBlock) * emitPerBlock * pool.allocPoint / totalAllocPoint;
        }
        return 0;
    }

    function updatePool(uint256 pid) public override {
        PoolInfo storage pool = poolInfo[pid];
        uint256 _lastEmitBlock = pool.lastEmitBlock;
        if (block.number <= _lastEmitBlock) {
            return;
        }
        if (pool.allocPoint == 0) {
            pool.lastEmitBlock = block.number;
            return;
        }
        uint256 amount = (block.number - _lastEmitBlock) * emitPerBlock * pool.allocPoint / totalAllocPoint;
        dubu.mint(owner(), amount / 10);
        dubu.mint(pool.to, amount);
        pool.lastEmitBlock = block.number;
    }

    function massUpdatePools() internal {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid += 1) {
            updatePool(pid);
        }
    }

    function add(address to, uint256 allocPoint) external onlyOwner {
        massUpdatePools();
        totalAllocPoint += allocPoint;
        poolInfo.push(PoolInfo({
            to: to,
            allocPoint: allocPoint,
            lastEmitBlock: block.number > startBlock ? block.number : startBlock
        }));
        emit Add(to, allocPoint);
    }

    function set(uint256 pid, uint256 allocPoint) external onlyOwner {
        massUpdatePools();
        totalAllocPoint = totalAllocPoint - poolInfo[pid].allocPoint + allocPoint;
        poolInfo[pid].allocPoint = allocPoint;
        emit Set(pid, allocPoint);
    }
}
