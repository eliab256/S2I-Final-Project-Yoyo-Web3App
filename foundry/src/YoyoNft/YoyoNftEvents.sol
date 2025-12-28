//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

event YoyoNft__WithdrawCompleted(uint256 amount, uint256 timestamp);
event YoyoNft__DepositCompleted(uint256 amount, uint256 timestamp);
event YoyoNft__MintPriceUpdated(uint256 newBasicPrice, uint256 timestamp);
event YoyoNft__NftMinted(address indexed owner, uint256 indexed tokenId, string tokenURI, uint256 timestamp);
