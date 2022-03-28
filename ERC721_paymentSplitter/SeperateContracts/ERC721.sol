// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/*
2 Contracts 

1. SplitPayments - deploy this first to use the address of the Main contract
    File "./PaymentSplitter.sol"

2. NFTMARKET this is the main project. 30000000000000000

*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract NFTMARKET is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public tokenCount;

    uint256 public mintRate = 0.03 ether; // 
    uint256 public MAX_SUPPLY = 8888;

    string public baseURI = 'ipfs://Qmcx1H7KqzNtM6nvr9qisiXBKYoHQAMkkaoTU2MoW4iok2/';
    // hide the mintable NFT, unless revealed
    bool public revealed = false;

    address payable paymentSplitterAddress; //address of paymentsplitter Contract

    constructor(address _paymentSplitterAddress) ERC721('NFTMARKET', 'NFT') {
        paymentSplitterAddress = payable(_paymentSplitterAddress);
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
            return bytes(_getbaseURI).length > 0 ? string(abi.encodePacked(_getbaseURI, Strings.toString(tokenId), ".jpg")) : "";
        } else {
            return string(abi.encodePacked(_getbaseURI, "hidden.jpg"));
        }   
    }

    function withdraw() public payable onlyOwner{
        // this function is used to transfer all the payments to PaymentSplitter contract.
        (bool success,) = payable(paymentSplitterAddress).call{value: address(this).balance}("");
        require(success);
    }
}