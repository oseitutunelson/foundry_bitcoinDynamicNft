//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

/**
 * @title Dynamic Nft
 * @author Owusu Nelson Osei Tutu
 * @notice This is a contract of a dynamic nft that depends on the current price of ethereum
 * there are two nfts to represent when the price is below $3000 and above
 * It uses chainlink automation to achieve this
 */

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from './PriceConverter.sol';
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract EtherNft is ERC721,AutomationCompatibleInterface{
    //errors
    error EtherNft__UpkeepNotNeeded();

    //state variables
    using PriceConverter for uint256;
    uint256 public s_tokenCounter;
    string public s_priceBefore;
    string public s_priceAfter;
    AggregatorV3Interface public s_priceFeed;

    enum Price {
        LOW,
        HIGH
    }

    // token id to Price
    mapping(uint256 => Price) public s_tokenIdToPrice;

    constructor(string memory priceBefore, string memory priceAfter, address priceFeed)
        ERC721("EtherNft", "ETN")
    {
        s_tokenCounter = 0;
        s_priceBefore = priceBefore;
        s_priceAfter = priceAfter;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    // function of baseURI
    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    //flip nft
    function flipNft(uint256 tokenId) public view{
        if(s_tokenIdToPrice[tokenId] == Price.LOW){
            s_tokenIdToPrice[tokenId] == Price.HIGH;
        }else{
            s_tokenIdToPrice[tokenId] == Price.LOW;
        }
    }

    //this is the function to flip the nft
    /**
     * @dev This is th function that the chainlink automation node calls to see if 
     * it should perform an upkeep
     * the following must be true to perform the upkeep
     * 1. The current price of eth should exceed $3000 dollars
     * 2. (Implicit) the subscription is funded with LINK
     */
    function checkUpkeep(bytes memory /* checkData */)public
        view override
        returns (bool upkeepNeeded, bytes memory /* performData */){
         uint256 ethAmount = 1;
         uint256 ethAmountInUsd = 3000000000000;
         bool amountHasExceeded = ethAmount.getConversionRate(s_priceFeed) >= ethAmountInUsd;
         upkeepNeeded = amountHasExceeded;
         return (upkeepNeeded,'0x0');
     }

    function performUpkeep(bytes calldata /* performData */) external view override{
        (bool upkeepNeeded,) = checkUpkeep("");
        if(!upkeepNeeded){
            revert EtherNft__UpkeepNotNeeded();
        }
        flipNft(0);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;
        if (s_tokenIdToPrice[tokenId] == Price.LOW) {
            imageURI = s_priceBefore;
        } else {
            imageURI = s_priceAfter;
        }
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT that reflects the current price of BTC, 100% on Chain!", ',
                                '"attributes": [{"trait_type": "price", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
