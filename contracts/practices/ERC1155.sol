// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC1155,IERC165} from "./IERC1155.sol";
import {IERC1155MetadataURI} from "./IERC1155MetadataURI.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC1155Receiver} from "./IERC1155Receiver.sol";

/**
 * @title ERC1155 多种代币标准
 * @dev   https://eips.ethereum.org/EIPS/eip-1155
 */
contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI{
    using Address for address;
    using Strings for uint256;

//    token 名称
    string public name;
//    token代号
    string public symbol;
//    代币种类id 到账户account 到 余额 balances的映射
    mapping(uint => mapping(address => uint)) public _balances;
//    address 到授权地址 的批量授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool){
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId;
    }

    function balanceOf(address account, uint id) public view virtual override returns (uint) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] calldata accounts, uint[] calldata ids) public view virtual override returns (uint[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
        uint[] memory batchBalances = new uint[](accounts.length);
        for (uint i = 0; i < accounts.length; i++) {
            batchBalances[i] = balanceOf(accounts[i],ids[i]);
        }
        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        uint amount,
        bytes memory data
    )
        external
        virtual
        override
    {
        address operator = msg.sender;
//        调用者是持有者或者是被授权
        require(from == operator || isApprovedForAll(from,operator), "ERC1155: caller is not token owner nor approved");
        require(to != address(0), "ERC1155: transfer to the zero address");
        uint fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");

//        更新持仓量 Overflow not possible: value <= fromBalance
        unchecked {
//        节省gas
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to,id,amount);
//        安全检查
        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint[] calldata ids,
        uint[] calldata amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        address operator = msg.sender;
        require(from == operator || _operatorApprovals[from][operator], "ERC1155: caller is not token owner nor approved");

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        for (uint i = 0; i < ids.length; i++) {
            uint id = ids[i];
            uint amount = amounts[i];

            uint fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to ,ids, amounts);
        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _mint(address to, uint id, uint amount, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        address operator = msg.sender;
        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);
        _doSafeTransferAcceptanceCheck(operator,address(0), to, id, amount, data);
    }

    function _mintBatch(address to, uint[] calldata ids, uint[] calldata amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }
        emit TransferBatch(operator, address(0), to, ids, amounts);
        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address from, uint id, uint amount) internal virtual{
        require(from != address(0), "ERC1155: burn from the zero address");
        address operator = msg.sender;
        uint fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");

        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id , amount);
    }

    function _burnBatch(address from, uint[] calldata ids, uint[] calldata amounts) internal{
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint i = 0; i < ids.length; i++) {
            uint fromBalance = _balances[ids[i]][from];
            require(fromBalance >= amounts[i], "ERC1155: burn amount exceeds balance");
            
            unchecked {
                _balances[ids[i]][from] = fromBalance - amounts[i];
            }
            emit TransferBatch(operator, address(0), from, ids, amounts);
        }
    }

    function uri(uint id) public view virtual override returns (string memory) {
        string  memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint id ,
        uint amount,
        bytes memory data
    )
        private
    {
        if (to.code.length >0) {
            try IERC1155Receiver(to).onREC1155Received(operator, from, id,amount, data) returns (bytes4 response){
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address to,
        address from,
        uint[] calldata ids,
        uint[] calldata amounts,
        bytes memory data
    )
        private
    {
        if (to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts ,data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error (string memory reason){
                    revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }
}
