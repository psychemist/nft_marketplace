// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./NFTCollection.sol";
import "./NFTHelpers.sol";

contract NFTFactory is NFTHelpers {
    uint256 public collectionId;

    NFTCollection[] public nftClones;

    mapping(uint256 => NFTCollection) nftCollections;
    // collection id -> nft id -> buyer address -> sent trade value check
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public hasTraded;

    function createNFTCollection(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
    ) returns (NFTCollection newNFT_) {
        _checkZeroAddress();

        newNFT_ = new NFTCollection(_name, _symbol, _totalSupply);

        nftClones.push(newNFT_);
        nftCollections[++collectionId] = newNFT_;
    }

    function tradeNFT(uint256 _tokenId) external {
        _checkZeroAddress();

        require(!isListed[_tokenId], NFTAlreadyListed());
    }

    function getNFTCollection(uint256 _collectionId) returns (NFTCollection) {
        require(_collectionId <= nftClones.length, NFTCollectionDoesNotExist());

        NFTCollection collection = nftCollections[_collectionId];

        require(collection.tokenId > 0, NFTCollectionDoesNotExist());

        return collection;
    }

    function getNFTCollections() returns (NFTCollection[] memory) {
        return nftClones();
    }
}
