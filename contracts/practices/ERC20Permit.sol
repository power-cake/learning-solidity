// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20Permit} from "./IERC20Permit.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {v1} from "./UpgradeableProxy.sol";

/**
 * @title 
 * @dev   
 */
contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using ECDSA for bytes32;

    mapping(address => uint) private _nonces;

    bytes32 private constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name, string memory symbol) ERC20 (name, symbol) EIP712(name, "1") {}
    
    /**
     * @dev
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        override
    {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

//        从签名和消息计算signer, 并验证签名
        address signer = hash.recover(v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view virtual override returns (uint) {
        return _nonces[owner];
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner) internal virtual returns (uint current) {
        current = _nonces[owner];
        _nonces[owner] += 1;
    }
}
