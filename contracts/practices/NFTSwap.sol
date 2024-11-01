// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721Receiver} from "./ERC721.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";


/**
 * @title 卖家：出售NFT的一方，可以挂单list、撤单revoke、修改价格update。
          买家：购买NFT的一方，可以购买purchase。
          订单：卖家发布的NFT链上订单，一个系列的同一tokenId最多存在一个订单，其中包含挂单价格price和持有人owner信息。当一个订单交易完成或被撤单后，其中信息清零。
 * @dev
 */
contract NFTSwap is IERC721Receiver{
    event List(address indexed seller, address indexed nftAddr, uint indexed tokenId, uint price);
    event Update(address indexed seller, address indexed nftAddr, uint indexed tokenId, uint newPrice);
    event Revoke(address indexed seller, address indexed nftAddr, uint indexed tokenId);
    event Purchase(address indexed buyer, address indexed nftAddr, uint tokenId, uint price);

//     定义order结构体
    struct Order {
        address owner;
        uint256 price;
    }

//    nft order 映射
    mapping(address => mapping(uint => Order)) public nftList;

    fallback() external payable {}

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    function list(address _nftAddr, uint _tokenId, uint _price) external {
        IERC721 nft = IERC721(_nftAddr);
        require(nft.getApproved(_tokenId) == address(this), "Need Approved");
        require(_price > 0);

        Order storage  order = nftList[_nftAddr][_tokenId];
        order.owner = msg.sender;
        order.price = _price;
//        将nft转账到合约
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
//        释放List事件
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    function revoke(address _nftAddress, uint _tokenId) external {
        Order storage order = nftList[_nftAddress][_tokenId];
//        必须由持有人发起
        require(order.owner == msg.sender, "Not owner");
        IERC721 nft = IERC721(_nftAddress);
//        nft要在合约中
        require(nft.ownerOf(_tokenId) == address(this), "Invalid order");

//        将nft转给卖家
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddress][_tokenId];

        emit Revoke(msg.sender, _nftAddress, _tokenId);
    }

    function update(address _nftAddr, uint _tokenId , uint _newPrice) external {
        require(_newPrice >0, "Invalid Price");
        Order storage  order = nftList[_nftAddr][_tokenId];
        require(order.owner == msg.sender, "Not Owner");

        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        order.price = _newPrice;
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    function purchase(address _nftAddr, uint _tokenId) external payable {
        Order storage order = nftList[_nftAddr][_tokenId];
        require(msg.value >= order.price, "Insufficient value");

        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == address(this), "Invalid Order");

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        payable(order.owner).transfer(order.price);
        payable(msg.sender).transfer(msg.value - order.price);

        delete nftList[_nftAddr][_tokenId];

        emit Purchase(msg.sender, _nftAddr, _tokenId, order.price);
    }
}
