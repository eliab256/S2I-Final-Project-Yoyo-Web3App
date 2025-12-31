//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error YoyoAuction__NotOwner();
error YoyoAuction__InvalidAddress();
error YoyoAuction__ThisContractDoesntAcceptDeposit();
error YoyoAuction__CallValidFunctionToInteractWithContract();
error YoyoAuction__InvalidTokenId();
error YoyoAuction__InvalidValue();
error YoyoAuction__AuctionNotOpen();
error YoyoAuction__BidTooLow();
error YoyoAuction__AuctionDoesNotExist();
error YoyoAuction__NoFailedRefundsToClaim();
error YoyoAuction__PreviousBidderRefundFailed();
error YoyoAuction__NoTokenToClaim();
error YoyoAuction__NotAuctionWinner();
error YoyoAuction__AuctionNotClosed();
error YoyoAuction__NftNotHeldByContract();
error YoyoAuction__NftAlreadyMinted();
error YoyoAuction__CannotChangeMintPriceDuringOpenAuction();
error YoyoAuction__AuctionStillOpen();
error YoyoAuction__UpkeepNotNeeded();
error YoyoAuction__NftContractNotSet();
error YoyoAuction__NftContractAlreadySet();
error YoyoAuction__OnlyChainlinkAutomationOrOwner();
error YoyoAuction__AuctionAlreadyEnded();
error YoyoAuction__WinnerHasUnclaimedToken();
