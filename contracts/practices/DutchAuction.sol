// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title 荷兰拍卖
 * @dev   x
 */
interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external;
}

contract DutchAuction {
    uint  private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable  public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor (
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    )
    {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price < discount"
        );

        nft = IERC721(_nft);
        nftId = _nftId;
    }

//    start price - discountRata * timeElapsed;
    function getPrice() public view returns (uint) {
        return startingPrice - discountRate * (block.timestamp-startAt);
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expried");

        uint price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint refund = msg.value - price;
        if (refund > 0 ) {
            payable(msg.sender).transfer(refund);
        }
        selfdestruct(seller);
    }

}
