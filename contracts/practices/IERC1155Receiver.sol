// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @dev ERC1155接收合约,需要接受ERC1155转账,需要实现这个合约
 */
interface IERC1155Receiver is IERC165{

    /**
     * @dev 接受ERC1155 安全转账 safeTransferFrom
     */
    function onREC1155Received(
        address operator,
        address from,
        uint id,
        uint value,
        bytes calldata data)
    external returns (bytes4);

    /**
     * @dev 接受ERC1155批量安全转账`safeBatchTransferFrom`
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
