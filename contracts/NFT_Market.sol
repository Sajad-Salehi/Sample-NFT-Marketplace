// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract NFTMarketplace is ReentrancyGuard {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;
    mapping(address => uint256) private UserNFTsNumber;


    struct MarketItem {

        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;


    event MarketItemCreated (

        uint256 tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    constructor() {
        owner = payable(msg.sender);
    }


    function updateListingPrice(uint _listingPrice) public payable {

        require(owner == msg.sender, "Only marketplace owner can update listing price.");
        listingPrice = _listingPrice;
    }
    
    function getListingPrice() public view returns (uint256) {

        return listingPrice;
    }


    function createMarketItem(address nftContract ,uint256 tokenId, uint256 price) private nonReentrant {

        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        idToMarketItem[tokenId] =  MarketItem(

            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId, msg.sender, address(this), price, false);

    }

    
    function createMarketSale(address nftContract, uint256 tokenId) public payable nonReentrant {

        uint price = idToMarketItem[tokenId].price;
        address seller = idToMarketItem[tokenId].seller;

        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));

        _itemsSold.increment();

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(seller).transfer(msg.value);

        UserNFTsNumber[owner] += 1;
        UserNFTsNumber[seller] -= 1;
    }

    function getNFT_numbers() public view returns(uint256) {

        return UserNFTsNumber[msg.sender];
    } 
}