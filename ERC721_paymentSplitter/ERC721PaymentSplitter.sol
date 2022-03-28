// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
ERC721 Payment Splitter Contract 

    1. Contract deployment needs 2 parameters:
        this paramameters are required to deploy the contract and addes the account for payment splitter
        1.1. PaymentSplitterAddress - list address of the PaymentSplitter Contract 
            1. e.g. ["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
        1.2. PaymentSplitterShare - percent of shares to distribute with multiple accounts
            1. e.g. [50, 50]
    2. mintRate: 0.03 ether // this is the minimum amount of ethers to mint a token
    3. MAX_SUPPLY: 8888 // this is the maximum amount of tokens that can be minted
    4. baseURI: 'ipfs://Qmcx1H7KqzNtM6nvr9qisiXBKYoHQAMkkaoTU2MoW4iok2/' // this is the base URI for the NFT
        4.1. to updated this base URI we have a function to update it later to publically reveal the minted NFTs.
    5. revealed: false // this is the flag to hide the mintable NFT, unless revealed
        5.1. to reveal the NFTs, pass a parameter true in updateReveal function, it will then allow the NFTs to be revealed and accessable.
    6. tokenURI: by default token url and minted tokens are hidden with hidden.json, unless revealed.

*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract NFTMARKET is ERC721URIStorage, PaymentSplitter, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public tokenCount;

    uint256 public mintRate = 0.03 ether; 
    uint256 public MAX_SUPPLY = 8888;

    string public baseURI = 'ipfs://Qmcx1H7KqzNtM6nvr9qisiXBKYoHQAMkkaoTU2MoW4iok2/';
    // hide the mintable NFT, unless revealed
    bool public revealed = false;

    address payable paymentSplitterAddress; //address of paymentsplitter Contract

    constructor(address[] memory _payees, uint[] memory _shares) ERC721('NFTMARKET', 'NFT') PaymentSplitter(_payees, _shares) payable {
    }

    function mintNFT(string memory _tokenUri) public payable returns (uint){
        tokenCount.increment();
        uint256 newItemId = tokenCount.current();
        require(newItemId < MAX_SUPPLY, "Can't Mint more NFT!");
        require(msg.value >= mintRate, "Not enough Ethers!");
        
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, _tokenUri);
        return newItemId;
    }

    function _baseURI() internal view override returns (string memory){
        return baseURI;
    }

    function _setTokenURI(string memory _newURI) public onlyOwner{
        baseURI = _newURI;
    }

    function updateReveal(bool _reveal) public onlyOwner{
        revealed = _reveal;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory _getbaseURI = _baseURI();

        // if the token is not revealed, return the baseURI. with hidden json.
        if (revealed) {
            return bytes(_getbaseURI).length > 0 ? string(abi.encodePacked(_getbaseURI, Strings.toString(tokenId))) : "";
        } else {
            return string(abi.encodePacked(_getbaseURI, "hidden.jpg"));
        }   
    }
}