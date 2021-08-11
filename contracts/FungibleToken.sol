// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IFungibleToken.sol";
import "./interfaces/IERC1271.sol";

contract FungibleToken is ERC20, IFungibleToken {

    string public override version;

    bytes32 public immutable override DOMAIN_SEPARATOR;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    
    mapping(address => uint256) public override nonces;

    constructor(
        string memory name,
        string memory symbol,
        string memory _version
    ) ERC20(name, symbol) {
        version = _version;

        uint256 chainId; assembly { chainId := chainid() }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(_version)),
                chainId,
                address(this)
            )
        );
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override(ERC20, IERC20) returns (bool) {
        uint256 _allowance = super.allowance(from, msg.sender);
        if (_allowance != type(uint256).max) {
            _approve(from, _msgSender(), _allowance - amount);
        }
        _transfer(from, to, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(block.timestamp <= deadline);

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner], deadline))
            )
        );
        nonces[owner] += 1;

        require(spender != owner);

        if (Address.isContract(owner)) {
            require(IERC1271(owner).isValidSignature(digest, abi.encodePacked(r, s, v)) == 0x1626ba7e);
        } else {
            address recoveredAddress = ecrecover(digest, v, r, s);
            require(recoveredAddress != address(0));
            require(recoveredAddress == owner);
        }

        _approve(owner, spender, value);
    }
}