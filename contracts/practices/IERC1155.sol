// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC1155 is IERC165{

    /**
     * @dev 单币种转账事件
     * 当`value` 个 `id` 种类多代币被`operator` 从 from 转账到 to 时释放
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint id ,uint value);

    /**
     * @dev 批量代币转账事件
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint[] ids, uint[] values);

    /**
     * @dev 批量授权事件
     * 当`account` 将所有代币授权给`operator`时释放
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev 当 id 种类的代币URI发生变化时释放， value 为新的uri
     */
    event URI(string value, uint indexed id);

    /**
     * @dev 持仓查询，返回 account 拥有 id 代币的 数量
     */
    function balanceOf(address account, uint id) external view returns (uint);

    /**
     * @dev 批量持仓查询， accounts 和 ids 数组的长度要相等
     */
    function balanceOfBatch(address[] calldata accounts, uint[] calldata ids) external view returns (uint[] memory);

    /**
     * @dev 批量授权,将调用者的代币授权给 `operator` 地址
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev 批量授权查询,如果授权地址 operator 被 account 授权, 则返回 true
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev 安全转账
     * 释放 TransferSingle 事件
     * - 如果调用者地址不是from地址而是授权地址,则需要得到 from 的授权
     * - from 地址必须有足够的持仓
     * - 如果接收方是合约地址, 需要实现 IERC1155Receiver 的 onERC1155Received 方法,并返回相应的值
     */
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes calldata data) external;

    /**
     * @dev 批量安全转账
     * 释放  TransferBatch 事件
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint[] calldata ids,
        uint[] calldata values,
        bytes calldata data)
    external;
}


