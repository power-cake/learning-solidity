// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

/**
 * @dev ERC20 Permit 扩展的接口, 允许通过签名进行批准. 如 https://eips.ethereum.org/EIPS/eip-2612[EIP-2612] 中的定义
 */
interface IERC20Permit {
    
    /**
     * @dev  根据owner 的签名, 将 owner 的erc20 余额授权给 spender ,数量为 value
     */
    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev 返回owner 的当前 nonce, 每次为 permit 生成签名时, 都必须返回此值
     */
    function nonces(address owner) external view returns (uint);
    
    /**
     * @dev 返回用于编码 permit 的签名 的域分隔符
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
