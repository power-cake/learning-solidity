// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

 /**
 * @title 英式拍卖
 * @dev   x
 */

interface IERC721 {
    function transferFrom(address from, address to, uint nftId) external;
}

contract EnglishAuction {
    IERC721 public immutable nft;
    uint public immutable nftId;
    
    event Start();
    event Bid(address indexed bidder, uint amount);
    event Withdraw(address indexed bidder, uint amount);
//    结束的只会触发一次，不用添加indexed
    event End(address highestBidder, uint amount);

    address payable public immutable seller;
    uint32 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public bids;

    constructor(
        address _nft,
        uint _nftId,
        uint _startingBid
    ) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
    }

    function start() external {
        require(msg.sender == seller, "not seller");
        require(!started, "already started");
        started = true;
        endAt = uint32(block.timestamp + 1 days);
        nft.transferFrom(seller, address(this), nftId);
        emit Start();
    }

    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest bid");
//        退还上一个用户的代币
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint amount = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function end() external  {
        require(started, "not started");
        require(!ended,"ended");
        require(block.timestamp > endAt, "not ended");
        ended = true;
        if (highestBidder != address(0)) {
            nft.transferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        }else {
//           没人拍就退回原用户
            nft.transferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}
