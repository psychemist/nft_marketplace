// SPDX-License-Identifier: SMIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721";

abstract contract NFTHelpers is AccessControl, ERC721, Ownable {
    error IncorrectFundsSupplied();
    error NFTAlreadyListed();
    error NFTCollectionDoesNotExist();
    error NFTDoesNotExist();
    error NFTNotListed();
    error SenderIsOwner();
    error SenderIsNotOwner();
    error TransferFailed();
    error ZeroAddressDetected();

    event NFTDeListed(address indexed owner, uint256 indexed tokenId);
    event NFTListed(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTReListed(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTMinted(address indexed minter, uint256 indexed tokenId);
    event NFTSold(
        address indexed buyer,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTTraded(
        address indexed previousOwner,
        address indexed newOwner,
        uint256 indexed tokenId
    );
    event NFTTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event NFTCollectionTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function _checkZeroAddress() internal view {
        require(msg.sender != address(0), ZeroAddressDetected());
    }

    function _checkOwner() internal view override {
        require(msg.sender == owner(), SenderIsNotOwner());
    }
}
