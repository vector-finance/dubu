// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "./interfaces/IHanulRNG.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IPriceCalculator.sol";

contract CakePot is Ownable {

    IHanulRNG private rng = IHanulRNG(0x92eE48b37386b997FAF1571789cd53A7f9b7cdd7);
    IBEP20 private constant CAKE = IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IMasterChef private constant CAKE_MASTER_CHEF = IMasterChef(0x73feaa1eE314F8c655E354234017bE2193C9E24E);
    IPriceCalculator private constant priceCalculator = IPriceCalculator(0xF5BF8A9249e3cc4cB684E3f23db9669323d4FB7d);
    
    uint256 public period = 720;
    uint256 public currentSeason = 0;
    uint256 public startSeasonBlock;

    mapping(uint256 => uint256) public userCounts;
    mapping(uint256 => mapping(address => uint256)) public amounts;
    mapping(uint256 => mapping(address => uint256)) public weights;
    mapping(uint256 => uint256) public totalWeights;
    
    mapping(uint256 => uint256) public maxSRCounts;
    mapping(uint256 => uint256) public maxRCounts;
    mapping(uint256 => uint256) public ssrRewards;
    mapping(uint256 => uint256) public srRewards;
    mapping(uint256 => uint256) public rRewards;
    mapping(uint256 => uint256) public nRewards;

    mapping(uint256 => address) public ssrs;
    mapping(uint256 => address[]) public srs;
    mapping(uint256 => address[]) public rs;
    mapping(uint256 => mapping(address => bool)) public exited;

    constructor() {
        CAKE.approve(address(this), type(uint256).max);
        startSeasonBlock = block.number;
    }

    function setRNG(IHanulRNG _rng) external onlyOwner {
        rng = _rng;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    function enter(uint256 amount) external {
        require(amount > 0);
        require(block.number - startSeasonBlock <= period);

        if (amounts[currentSeason][msg.sender] == 0) {
            userCounts[currentSeason] += 1;
        }
        
        amounts[currentSeason][msg.sender] += amount;
        uint256 weight = (period - (block.number - startSeasonBlock)) * amount;
        weights[currentSeason][msg.sender] += weight;
        totalWeights[currentSeason] += weight;

        CAKE.transferFrom(msg.sender, address(this), amount);
        CAKE_MASTER_CHEF.enterStaking(amount);
    }

    function end() external {
        require(block.number - startSeasonBlock > period);

        uint256 userCount = userCounts[currentSeason];
        (uint256 staked,) = CAKE_MASTER_CHEF.userInfo(0, address(this));
        CAKE_MASTER_CHEF.leaveStaking(staked);
        uint256 balance = CAKE.balanceOf(address(this));
        uint256 totalReward = balance - staked;

        // ssr
        uint256 ssrReward = totalReward * 3 / 10; // 30%
        ssrRewards[currentSeason] = ssrReward;

        // sr
        uint256 maxSRCount = userCount / 10; // 10%
        uint256 totalSRReward = totalReward / 5; // 20%
        maxSRCounts[currentSeason] = maxSRCount;
        srRewards[currentSeason] = totalSRReward / maxSRCount;

        // r
        uint256 maxRCount = userCount / 5; // 20%
        uint256 totalRReward = totalReward / 10; // 10%
        maxRCounts[currentSeason] = maxRCount;
        rRewards[currentSeason] = totalRReward / maxRCount;

        // n
        srRewards[currentSeason] = (totalReward - ssrReward - totalSRReward - totalRReward) / userCount;

        // start next season.
        currentSeason += 1;
        startSeasonBlock = block.number;
    }

    function exit(uint256 season) external {
        require(season < currentSeason);
        require(exited[season][msg.sender] != true);

        uint256 a = userCounts[season] * totalWeights[season] / weights[season][msg.sender];
        uint256 k = (rng.generateRandomNumber(season, msg.sender) % 100) * a;
        if (ssrs[season] == address(0) && k == 0) { // 1%, ssr
            ssrs[season] = msg.sender;
            CAKE.transfer(msg.sender, ssrRewards[season]);
        }
        
        k = (rng.generateRandomNumber(season, msg.sender) % 100) * a;
        if (srs[season].length < maxSRCounts[season] && k < 10) { // 10%, sr
            srs[season].push(msg.sender);
            CAKE.transfer(msg.sender, srRewards[season]);
        }
        
        k = (rng.generateRandomNumber(season, msg.sender) % 100) * a;
        if (rs[season].length < maxRCounts[season] && k < 20) { // 20%, r
            rs[season].push(msg.sender);
            CAKE.transfer(msg.sender, rRewards[season]);
        }

        // n
        CAKE.transfer(msg.sender, nRewards[season]);

        exited[season][msg.sender] = true;
    }
}
