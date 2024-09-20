// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "./NFTHelpers.sol";

contract NFTCollection is NFTHelpers {
    uint256 public tokenId;
    uint256 public totalSupply;

    struct Nft {
        uint256 id;
        uint256 price;
        string metadata;
        address owner;
    }

    Nft[] public allNFTs;

    mapping(uint256 => Nft) public nfts;
    mapping(uint256 => bool) public isListed;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
    ) ERC721(_name, _symbol) {
        totalSupply = _totalSupply;
    }

    function mintNFT(string memory _tokenURI) external returns (uint256) {
        _checkZeroAddress();

        uint256 newItemId = ++tokenId;

        Nft storage nft;
        nft.id = newItemId;
        nft.owner = msg.sender;
        nft.metadata = _tokenURI;

        if (newItemId <= totalSupply) {
            _safeMint(msg.sender, newItemId);
            _setTokenURI(newItemId, _tokenURI);
        }

        allNFTs.push(nft);

        return newItemId;

        emit NFTMinted(msg.sender, _tokenId);
    }

    function listNFT(uint256 _tokenId, uint256 _price) external {
        _checkZeroAddress();

        require(!isListed[_tokenId], NFTAlreadyListed());

        Nft storage nft = nfts[_tokenId];

        require(nft.id != 0, NFTDoesNotExist());
        require(nft.owner == msg.sender, SenderIsNotOwner());

        nft.price = _price;
        isListed[_tokenId] = true;

        emit NFTListed(msg.sender, _tokenId, _price);
    }

    function delistNFT(uint256 _tokenId, uint256 _price) external {
        _checkZeroAddress();

        require(isListed[_tokenId], NFTNotListed());

        Nft storage nft = nfts[_tokenId];

        require(nft.id != 0, NFTDoesNotExist());
        require(nft.owner == msg.sender, SenderIsNotOwner());

        nft.price = 0;
        isListed[_tokenId] = false;

        emit NFTDeListed(msg.sender, _tokenId, _price);
    }

    function relistNFT(uint256 _tokenId, uint256 _newPrice) external {
        _checkZeroAddress();

        require(isListed[_tokenId], NFTNotListed());

        Nft storage nft = nfts[_tokenId];

        require(nft.id != 0, NFTDoesNotExist());
        require(nft.owner == msg.sender, SenderIsNotOwner());

        nft.price = _newPrice;
        isListed[_tokenId] = true;

        emit NFTListed(msg.sender, _tokenId, _newPrice);
    }

    function buyNFT(uint256 _tokenId) external payable {
        _checkZeroAddress();

        require(isListed[_tokenId], NFTNotListed());

        Nft storage nft = nfts[_tokenId];
        address nftOwner = nft.owner;

        require(nft.id != 0, NFTDoesNotExist());
        require(nftOwner != msg.sender, SenderIsOwner());

        uint256 nftPrice = nft.price;
        uint256 netPrice = (nftPrice * 0.99 * 1000) / 1000 wei;

        require(msg.value == nftPrice, InsufficientFundsSent());

        nft.owner = msg.sender;
        allNFTs[--tokenId] = nft;

        _safeTransfer(nftOwner, msg.sender, _tokenId);

        require(nftOwner.call{value: netPrice}(""), TransferFailed());

        emit NFTSold(msg.sender, _tokenId, nftPrice);
    }

    function transferNFT(uint256 _tokenId, address _newOwner) external {
        _checkZeroAddress();

        require(_requireOwned(_tokenId) == msg.sender, SenderIsNotOwner());
        require(!isListed[_tokenId], NFTAlreadyListed());

        Nft storage nft = nfts[_tokenId];
        address nftOwner = nft.owner;

        require(nft.id != 0, NFTDoesNotExist());
        require(nftOwner == msg.sender, SenderIsNotOwner());

        nft.owner = _newOwner;
        allNFTs[--tokenId] = nft;

        _safeTransfer(nftOwner, _newOwner, _tokenId);

        emit NFTTransferred(msg.sender, _newOwner, _tokenId);
    }

    function transferNFTCollection(address _newOwner) external _checkOwner {
        _checkZeroAddress();

        transferOwnership(_newOwner);

        emit NFTCollectionTransferred(msg.sender, _newOwner);
    }

    function getNFTCount() external view {
        return allNFTs.length;
    }

    function withdraw(uint256 _amount) external _checkOwner {
        _checkZeroAddress();

        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, TransferFailed());
    }
}
