// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155} from "./ERC1155.sol";

/**
 * @title 类无聊猿的 erc1155合约
 * @dev   x
 */
contract BAYC1155 is ERC1155 {

    uint constant MAX_ID = 10000;

    constructor() ERC1155("BAYC1155", "BAYC1155"){

    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }

    function mint(address to, uint id, uint amount) external {
//        id 不能超过10000
        require(id < MAX_ID, "Id overflow");
        _mint(to, id, amount, "");
    }

    function mintBatch(address to, uint[] calldata ids, uint[] calldata amounts) external {
        for (uint i = 0; i < ids.length; i++) {
            require(ids[i] < MAX_ID, "Id overflow");
        }
        _mintBatch(to, ids, amounts,"");
    }
}
