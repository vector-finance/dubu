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
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
interface IFungibleToken is IERC20 {
    
    function version() external view returns (string memory);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT
interface IDubu is IFungibleToken {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
interface IDubuEmitter {

    event Add(address to, uint256 allocPoint);
    event Set(uint256 indexed pid, uint256 allocPoint);

    function dubu() external view returns (IDubu);
    function emitPerBlock() external view returns (uint256);
    function startBlock() external view returns (uint256);

    function poolCount() external view returns (uint256);
    function poolInfo(uint256 pid) external view returns (
        address to,
        uint256 allocPoint,
        uint256 lastEmitBlock
    );
    function totalAllocPoint() external view returns (uint256);

    function pendingToken(uint256 pid) external view returns (uint256);
    function updatePool(uint256 pid) external;
}

// SPDX-License-Identifier: MIT
interface IDubuDividend {

    event Distribute(address indexed by, uint256 distributed);
    event Claim(address indexed to, uint256 claimed);

    function totalTokenBalance() external view returns (uint256);
    function tokenBalances(address owner) external view returns (uint256);

    function accumulativeOf(address owner) external view returns (uint256);
    function claimedOf(address owner) external view returns (uint256);
    function claimableOf(address owner) external view returns (uint256);
    function claim() external;
}

// SPDX-License-Identifier: MIT
contract DubuDividend is IDubuDividend {

    IDubuEmitter private constant DUBU_EMITTER = IDubuEmitter(0xDDb921d4F0264c10884D652E3aB9704F8189DAf4);
    IBEP20 internal constant DUBU = IBEP20(0x972543fe8BeC404AB14e0c38e942032297f44B2A);

    uint256 private immutable pid;

    constructor() {
        pid = DUBU_EMITTER.poolCount();
    }

    uint256 internal currentBalance = 0;
    
    uint256 override public totalTokenBalance = 0;
    mapping(address => uint256) override public tokenBalances;

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