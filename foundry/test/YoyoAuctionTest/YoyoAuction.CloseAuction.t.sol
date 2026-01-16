//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoAuctionBaseTest } from './YoyoAuction.Base.t.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { AuctionType, AuctionState, AuctionStruct } from '../../src/YoyoTypes.sol';
import { YoyoNftFailingMintMock } from '../Mocks/YoyoNftFailingMintMock.sol';
import { Vm } from 'forge-std/Vm.sol';
import { console2 } from 'forge-std/console2.sol';

contract YoyoAuctionCloseAuctionTest is YoyoAuctionBaseTest {
    YoyoAuction public yoyoAuctionFailMint;
    YoyoNftFailingMintMock public yoyoNftFailMint;
    uint256 public auctionIdFailMint;
    string public failureReason = 'Mint failed for testing';

    ////// helpers /////
    function setNftContractFailingMintMock(bool _shouldFail, bool _throwPanicError) public {
        //Set new contracts that fails on mint
        vm.startPrank(deployer);
        yoyoAuctionFailMint = new YoyoAuction(keeperMock);
        yoyoNftFailMint = new YoyoNftFailingMintMock(helperConfig.getConstructorParams(address(yoyoAuctionFailMint)));
        yoyoAuctionFailMint.setNftContract(address(yoyoNftFailMint));

        yoyoNftFailMint.setShouldFailMint(_shouldFail, failureReason);
        yoyoNftFailMint.setShouldPanic(_throwPanicError);

        //open New Dutch Auction
        auctionIdFailMint = yoyoAuctionFailMint.openNewAuction(VALID_TOKEN_ID, DUTCH_TYPE);
        vm.stopPrank();
    }

    function placeBid(address _user) public {
        vm.startPrank(_user);
        uint256 newBidPlaced = yoyoAuctionFailMint.getCurrentAuctionPrice();
        yoyoAuctionFailMint.placeBidOnAuction{ value: newBidPlaced }(auctionIdFailMint);
        vm.stopPrank();
    }

    ////// close Auction //////
    function testCloseAuctionWorksWithDutchAuctionAndMintNft() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            auctionId,
            currentAuction.tokenId,
            currentAuction.startPrice,
            currentAuction.startTime,
            block.timestamp,
            USER_1,
            newBidPlaced
        );
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__AuctionFinalized(auctionId, currentAuction.tokenId, USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        vm.roll(block.number + 1);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.FINALIZED);
        assertEq(yoyoAuction.getAuctionFromAuctionId(auctionId).nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), USER_1);
    }

    function testCloseAuctionWorksWithEnglishAuctionAndMintNft() public {
        uint256 auctionId = openEnglishAuctionHelper();
        uint256 bidAmount = yoyoAuction.getAuctionFromAuctionId(auctionId).higherBid +
            yoyoAuction.getMinimumBidChangeAmount();
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(auctionId).endTime;
        placeBidHelper(auctionId, USER_1, bidAmount);

        vm.roll(block.number + 1);
        vm.warp(endTime);
        //PerformUpkeep check conditions and call closeAuction function
        vm.startPrank(keeperMock);
        yoyoAuction.performUpkeep(abi.encode(auctionId, endTime));
        vm.stopPrank();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        assertTrue(currentAuction.state == AuctionState.FINALIZED);
        assertEq(currentAuction.nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), USER_1);
    }

    function testAuctionContractCanReceiveNft() public {
        uint256 auctionId = openDutchAuctionHelper();
        uint256 bidAmount = yoyoAuction.getCurrentAuctionPrice();
        placeBidHelper(auctionId, USER_1, bidAmount);

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        assertTrue(currentAuction.state == AuctionState.FINALIZED);
        assertEq(currentAuction.nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), USER_1);

        vm.prank(USER_1);
        yoyoNft.transferNft(address(yoyoAuction), currentAuction.tokenId);

        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(yoyoAuction));
    }

    function testCloseAuctionFailingMintToUserAndUpdatesMapping() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.setThrowPanicError(false);

        //Place a bid on the auction
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        vm.roll(block.number + 1);

        AuctionStruct memory updatedAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertTrue(updatedAuction.state == AuctionState.CLOSED);
        assertEq(updatedAuction.nftOwner, address(yoyoAuction));
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(yoyoAuction));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 0);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);
    }

    function testCloseAuctionAndFailingMintOnAuctionContractEmitEvent() public {
        setNftContractFailingMintMock(true, false);

        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionFailMint.getCurrentAuctionPrice();

        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailed(auctionIdFailMint, VALID_TOKEN_ID, USER_1, failureReason);
        yoyoAuctionFailMint.placeBidOnAuction{ value: newBidPlaced }(auctionIdFailMint);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuctionFailMint.getAuctionFromAuctionId(auctionIdFailMint);

        assert(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));
        assertEq(yoyoNftFailMint.balanceOf(address(yoyoAuctionFailMint)), 0);
        assertEq(yoyoNftFailMint.balanceOf(USER_1), 0);
        assertEq(yoyoAuctionFailMint.getElegibilityForClaimingNft(auctionIdFailMint, USER_1), true);
    }

    //fare check
    function testCloseAuctionFailingMintToUserWithReasonAndEmitEvents() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);

        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            auctionId,
            currentAuction.tokenId,
            currentAuction.startPrice,
            currentAuction.startTime,
            block.timestamp,
            address(ethAndNftRefuseMock),
            newBidPlaced
        );

        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailed(auctionId, currentAuction.tokenId, address(ethAndNftRefuseMock), '');
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();
    }
    //fare check
    function testWhenFailingMintToUserWithPanicErrorAndEmitEvents() public {
        uint256 auctionId = openDutchAuctionHelper();
        uint256 tokenId = yoyoAuction.getAuctionFromAuctionId(auctionId).tokenId;
        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.setThrowPanicError(true);

        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            auctionId,
            tokenId,
            yoyoAuction.getAuctionFromAuctionId(auctionId).startPrice,
            yoyoAuction.getAuctionFromAuctionId(auctionId).startTime,
            block.timestamp,
            address(ethAndNftRefuseMock),
            newBidPlaced
        );
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailed(auctionId, tokenId, address(ethAndNftRefuseMock), 'unknown error');
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(yoyoAuction));
        assertEq(yoyoNft.ownerOf(tokenId), address(yoyoAuction));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 0);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);
    }

    ////// Claim mint for winner //////
    function testClaimNftRevertsIfNotEligible() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Place a bid on the auction
        placeBidHelper(auctionId, USER_1, newBidPlaced);

        vm.roll(block.number + 1);

        //Try to claim the NFT from an address not eligible
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__NoTokenToClaim.selector);
        yoyoAuction.claimNftForWinner(auctionId);
        vm.stopPrank();
    }

    function testClaimNftForWinnerWorksAfterNftMintedToAuctionContract() public {
        uint256 auctionId = openDutchAuctionHelper();
        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(auctionId).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.setThrowPanicError(false);

        //Place a bid on the auction
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(yoyoAuction));
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 0);

        vm.roll(block.number + 1);

        //Now allow the mock contract to receive the NFT
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(true);

        //Call claimNft function
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__AuctionFinalized(auctionId, currentAuction.tokenId, address(ethAndNftRefuseMock));
        ethAndNftRefuseMock.claimNftFromAuction(auctionId);
        vm.stopPrank();

        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(ethAndNftRefuseMock));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 1);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), false);
        assert(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.FINALIZED);
    }

    function testClaimNftForWinnerRevertsIfNotElegible() public {
        setNftContractFailingMintMock(true, false);
        placeBid(USER_1);

        AuctionStruct memory currentAuction = yoyoAuctionFailMint.getAuctionFromAuctionId(auctionIdFailMint);

        assert(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));
        assertEq(yoyoAuctionFailMint.getElegibilityForClaimingNft(auctionIdFailMint, USER_1), true);

        vm.prank(USER_2);
        vm.expectRevert(YoyoAuction__NoTokenToClaim.selector);
        yoyoAuctionFailMint.claimNftForWinner(auctionIdFailMint);
    }

    function testClaimNftForWinnerMintTheNft() public {
        setNftContractFailingMintMock(true, false);
        placeBid(USER_1);

        AuctionStruct memory currentAuction = yoyoAuctionFailMint.getAuctionFromAuctionId(auctionIdFailMint);

        assert(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));
        assertEq(yoyoNftFailMint.balanceOf(address(yoyoAuctionFailMint)), 0);
        assertEq(yoyoNftFailMint.balanceOf(USER_1), 0);
        assertEq(yoyoAuctionFailMint.getElegibilityForClaimingNft(auctionIdFailMint, USER_1), true);

        yoyoNftFailMint.setShouldFailMint(false, failureReason);
        vm.prank(USER_1);
        yoyoAuctionFailMint.claimNftForWinner(auctionIdFailMint);

        AuctionStruct memory currentAuctionUpdate = yoyoAuctionFailMint.getAuctionFromAuctionId(auctionIdFailMint);

        assertEq(yoyoNftFailMint.balanceOf(USER_1), 1);
        assertEq(yoyoAuctionFailMint.getElegibilityForClaimingNft(auctionIdFailMint, USER_1), false);
        assertEq(yoyoNftFailMint.ownerOf(VALID_TOKEN_ID), USER_1);
        assertEq(currentAuctionUpdate.nftOwner, USER_1);
        assert(currentAuctionUpdate.state == AuctionState.FINALIZED);
    }

    function testClaimNftFromWinnerTransferTheNftFromAuctionContractToUser() public {
        uint256 auctionId = openDutchAuctionHelper();
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Set the YoyoNft contract to refuse the mint
        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(false);
        ethAndNftRefuseMock.setThrowPanicError(false);

        //Place a bid on the auction
        ethAndNftRefuseMock.placeBid{ value: newBidPlaced }(auctionId);
        vm.stopPrank();

        vm.roll(block.number + 1);

        AuctionStruct memory currentAuction = yoyoAuction.getAuctionFromAuctionId(auctionId);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(yoyoAuction));
        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(yoyoAuction));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 0);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), true);

        vm.startPrank(USER_1);
        ethAndNftRefuseMock.setCanReceiveNft(true);
        ethAndNftRefuseMock.claimNftFromAuction(auctionId);
        vm.stopPrank();

        assertEq(yoyoNft.ownerOf(currentAuction.tokenId), address(ethAndNftRefuseMock));
        assertEq(yoyoNft.balanceOf(address(ethAndNftRefuseMock)), 1);
        assertEq(yoyoAuction.getElegibilityForClaimingNft(auctionId, address(ethAndNftRefuseMock)), false);
        assert(yoyoAuction.getAuctionFromAuctionId(auctionId).state == AuctionState.FINALIZED);
    }

    //testClaimNftForWinnerMintTheNft e provare che cattura l' errore se revert ancora
}
