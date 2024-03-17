// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Rudis {

    struct MarketItem{
        uint256 id;
        address nftContract;
        string nftUri;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;
    uint256 private itemCount;

    function createMarketItem(string memory _nftUri, uint256 _price)public{
        itemCount += 1;
        idToMarketItem[itemCount] = MarketItem(
            itemCount,
            msg.sender,
            _nftUri,
            payable(msg.sender),
            payable(msg.sender),
            _price,
            false
        );
    }

    function purchaseMarketItem(uint256 _id)public payable{
        MarketItem storage item = idToMarketItem[_id];
        require(item.sold == false, "Item is already sold");
        require(msg.value >= item.price, "Not enough ether sent");
        item.sold = true;
        item.owner = payable(msg.sender);
        item.seller.transfer(msg.value);
    }

    function fetchMarketItem()public view returns(MarketItem[] memory){
        MarketItem[] memory items = new MarketItem[](itemCount);
        for(uint i = 0; i < itemCount; i++){
            items[i] = idToMarketItem[i + 1];
        }
        return items;
    }

}