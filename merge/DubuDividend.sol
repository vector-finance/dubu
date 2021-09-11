pragma solidity ^0.8.5;


// SPDX-License-Identifier: GPL-3.0-or-later
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
interface IDubuDividend {

    event Distribute(address indexed by, uint256 distributed);
    event Claim(address indexed to, uint256 claimed);

    function accumulativeOf(address owner) external view returns (uint256);
    function claimedOf(address owner) external view returns (uint256);
    function claimableOf(address owner) external view returns (uint256);
    function claim() external;
}

// SPDX-License-Identifier: MIT
contract DubuDividend is IDubuDividend {

    IBEP20 private constant DUBU = IBEP20(0x0000000000000000000000000000000000000000);
    IBEP20 private token;

    constructor(IBEP20 _token) {
        token = _token;
    }

    uint256 internal currentBalance = 0;
    mapping(address => uint256) internal cakeBalances;

    uint256 constant internal pointsMultiplier = 2**128;
    uint256 internal pointsPerShare = 0;
    mapping(address => int256) internal pointsCorrection;
    mapping(address => uint256) internal claimed;

    function updateBalance() internal {
        uint256 totalBalance = token.balanceOf(address(this));
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
        uint256 totalBalance = token.balanceOf(address(this));
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