// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console } from 'forge-std/Test.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import '../../src/YoyoAuction/YoyoAuctionErrors.sol';
import '../../src/YoyoAuction/YoyoAuctionEvents.sol';
import { YoyoNft } from '../../src/YoyoNft/YoyoNft.sol';
import { YoyoNftMockFailingMint } from '../Mocks/YoyoNftMockFailingMint.sol';
import { RevertOnReceiverMock } from '../Mocks/RevertOnReceiverMock.sol';
import { DeployYoyoAuctionAndYoyoNft } from '../../script/DeployYoyoAuctionAndYoyoNft.s.sol';
import { ConstructorParams, AuctionType, AuctionState, AuctionStruct } from '../../src/YoyoTypes.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

//Il mock serve per testare i casi in cui si prova a inserire valori non validi dentro le enum
contract YoyoAuctionTest is Test {
    YoyoAuction public yoyoAuction;
    YoyoNft public yoyoNft;

    //Test Partecipants
    address public deployer;
    address public USER_1 = makeAddr('User1');
    address public USER_2 = makeAddr('User2');
    address public USER_NO_BALANCE = makeAddr('user no balance');

    uint256 public constant STARTING_BALANCE_YOYO_CONTRACT = 10 ether;
    uint256 public constant STARTING_BALANCE_AUCTION_CONTRACT = 10 ether;
    uint256 public constant STARTING_BALANCE_DEPLOYER = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_1 = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_2 = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_NO_BALANCE = 0 ether;

    function setUp() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft) = deployerScript.run();

        deployer = msg.sender;

        //Set up balances for each address
        vm.deal(deployer, STARTING_BALANCE_DEPLOYER);
        vm.deal(address(yoyoNft), STARTING_BALANCE_YOYO_CONTRACT);
        vm.deal(address(yoyoAuction), STARTING_BALANCE_AUCTION_CONTRACT);
        vm.deal(USER_1, STARTING_BALANCE_USER_1);
        vm.deal(USER_2, STARTING_BALANCE_USER_2);
        vm.deal(USER_NO_BALANCE, STARTING_BALANCE_USER_NO_BALANCE);
    }

    

    //Test checkUpkeep
    function testPerformeUpkeepCanOnlyRunIfCheckUpkeepReturnsTrue() public {
        vm.prank(deployer);
        yoyoAuction.openNewAuction(1, AuctionType.ENGLISH);

        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(1).endTime;
        uint256 auctionId = yoyoAuction.getAuctionFromAuctionId(1).auctionId;
        bytes memory performDataTest = abi.encode(auctionId);

        (bool upkeepNeeded, bytes memory performData) = yoyoAuction.checkUpkeep('');
        assertFalse(upkeepNeeded);
        assertEq(performDataTest, performData);

        vm.roll(block.number + 1);
        vm.warp(endTime);

        (upkeepNeeded, ) = yoyoAuction.checkUpkeep('');
        assertTrue(upkeepNeeded);
        assertEq(performDataTest, performData);
    }

    function testIfPerformUpkeepRevertsIfUpkeepNeededIsFalse() public {
        vm.prank(deployer);
        yoyoAuction.openNewAuction(1, AuctionType.ENGLISH);

        uint256 auctionId = yoyoAuction.getAuctionFromAuctionId(1).auctionId;
        bytes memory performDataTest = abi.encode(auctionId);

        vm.expectRevert(YoyoAuction__UpkeepNotNeeded.selector);
        yoyoAuction.performUpkeep(performDataTest);
    }

    function testIfPerformUpkeepCallCloseAuctionIfBidderIsNotZeroAddress() public {
        //Open New Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(1, AuctionType.ENGLISH);

        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(1).endTime;
        uint256 auctionId = yoyoAuction.getAuctionFromAuctionId(1).auctionId;
        uint256 tokenId = yoyoAuction.getAuctionFromAuctionId(1).tokenId;
        uint256 startPrice = yoyoAuction.getAuctionFromAuctionId(1).startPrice;
        uint256 startTime = yoyoAuction.getAuctionFromAuctionId(1).startTime;
        bytes memory performDataTest = abi.encode(auctionId);
        uint256 bidAmount = yoyoAuction.getAuctionFromAuctionId(1).higherBid + yoyoAuction.getMinimumBidChangeAmount();

        vm.roll(block.number + 1);
        vm.warp(endTime - 1 hours);

        //Place a Bid
        vm.startPrank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: bidAmount }(1);
        vm.stopPrank();

        vm.roll(block.number + 1);
        vm.warp(endTime);

        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionClosed(auctionId, tokenId, startPrice, startTime, endTime, USER_1, bidAmount);

        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.FINALIZED);
    }

    function testIfPerformUpkeepCallRestartEnglishAuctionCorrectlyIfBidderIsZeroAddress() public {
        //Open New Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(1, AuctionType.ENGLISH);

        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(1).endTime;
        uint256 auctionId = yoyoAuction.getAuctionFromAuctionId(1).auctionId;
        uint256 tokenId = yoyoAuction.getAuctionFromAuctionId(1).tokenId;
        uint256 startPrice = yoyoAuction.getAuctionFromAuctionId(1).startPrice;
        uint256 oldStartTime = yoyoAuction.getAuctionFromAuctionId(1).startTime;
        bytes memory performDataTest = abi.encode(auctionId);

        vm.roll(block.number + 1);
        vm.warp(endTime);

        uint256 newStartTime = block.timestamp;
        uint256 newEndTime = newStartTime + yoyoAuction.getAuctionDurationInHours() * 1 hours;

        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionRestarted(
            auctionId,
            tokenId,
            newStartTime,
            startPrice,
            newEndTime,
            yoyoAuction.getMinimumBidChangeAmount()
        );

        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.OPEN);
        assertTrue(oldStartTime < newStartTime);
    }

    function testIfPerformUpkeepCallRestartDutchAuctionCorrectlyIfBidderIsZeroAddress() public {
        //Open New Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(1, AuctionType.DUTCH);

        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(1).endTime;
        uint256 auctionId = yoyoAuction.getAuctionFromAuctionId(1).auctionId;
        uint256 tokenId = yoyoAuction.getAuctionFromAuctionId(1).tokenId;
        uint256 startPrice = yoyoAuction.getAuctionFromAuctionId(1).startPrice;
        uint256 oldStartTime = yoyoAuction.getAuctionFromAuctionId(1).startTime;
        bytes memory performDataTest = abi.encode(auctionId);

        vm.roll(block.number + 1);
        vm.warp(endTime);

        uint256 newStartTime = block.timestamp;
        uint256 newEndTime = newStartTime + yoyoAuction.getAuctionDurationInHours() * 1 hours;

        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__AuctionRestarted(
            auctionId,
            tokenId,
            newStartTime,
            startPrice,
            newEndTime,
            yoyoAuction.getMinimumBidChangeAmount()
        );

        yoyoAuction.performUpkeep(performDataTest);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.OPEN);
        assertTrue(oldStartTime < newStartTime);
    }

    //Test Place Bid
    function testIfPlaceBidOnAuctionRevertsIfDoesNotExist() public {
        uint256 invalidAuctionId = 10;
        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__AuctionDoesNotExist.selector);
        yoyoAuction.placeBidOnAuction{ value: 0.1 ether }(invalidAuctionId);
        vm.stopPrank();
    }

    function testIfPlaceBidOnAuctionRevertsIfAuctionIsNotOpen() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.DUTCH;

        //Open New Dutch Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        uint256 currentAuctionPrice = yoyoAuction.getAuctionFromAuctionId(1).higherBid;
        //Place a bid to close the auction
        vm.prank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: currentAuctionPrice }(1);

        //Try to place a bid on the same auction after it has been closed
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__AuctionNotOpen.selector);
        yoyoAuction.placeBidOnAuction{ value: currentAuctionPrice }(1);
        vm.stopPrank();
    }

    function testIfPlaceBidOnAuctionPlaceBidOnEnglishAuctionWorks() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.ENGLISH;
        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() + yoyoAuction.getMinimumBidChangeAmount();

        //Open New English Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(1, USER_1, newBidPlaced, auctionType);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBidder, USER_1);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBid, newBidPlaced);
        //if auction is English, should stay open after a bid is placed
        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.OPEN);
    }

    function testIfPlaceBidOnEnglishAuctionRevertsIfBidTooLowAndHigherBidUpdateCorrectly() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.ENGLISH;
        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() + yoyoAuction.getMinimumBidChangeAmount();

        //Open New English Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        //place first bid on the auction
        vm.startPrank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        //Try to place a bid that is too low
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__BidTooLow.selector);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBidder, USER_1);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBid, newBidPlaced);
    }

    function testIfPlaceBidOnEnglishAuctionRefundsPreviousBidder() public {
        uint256 user1InitialBalance = USER_1.balance;
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.ENGLISH;
        uint256 firstBid = yoyoNft.getBasicMintPrice() + yoyoAuction.getMinimumBidChangeAmount();
        uint256 secondBid = firstBid + yoyoAuction.getMinimumBidChangeAmount();

        //Open New English Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        //Place first bid on the auction
        vm.startPrank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: firstBid }(1);
        vm.stopPrank();

        uint256 user1BalanceAfterFirstBid = USER_1.balance;

        //Place second bid on the auction
        vm.startPrank(USER_2);
        vm.expectEmit(false, false, true, true);
        emit YoyoAuction__BidderRefunded(USER_1, firstBid, 1);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(1, USER_2, secondBid, auctionType);
        yoyoAuction.placeBidOnAuction{ value: secondBid }(1);
        vm.stopPrank();

        uint256 user1balanceAfterRefund = USER_1.balance;

        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBidder, USER_2);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBid, secondBid);
        assertEq(user1BalanceAfterFirstBid, user1InitialBalance - firstBid);
        assertEq(user1InitialBalance, user1balanceAfterRefund);
    }

    function testIfPlaceBidOnDutchAuctionWorksAndCloseTheCurrentAuction() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.DUTCH;
        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() * yoyoAuction.getDutchAuctionStartPriceMultiplier();

        //Open New Dutch Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, false, false);
        emit YoyoAuction__BidPlaced(1, USER_1, newBidPlaced, auctionType);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBidder, USER_1);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).higherBid, newBidPlaced);
        //if auction is Dutch, should close after a bid is placed
        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.FINALIZED);
    }

    function testIfPlaceBidOnDutchAuctionRevertsIfBidTooLow() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.DUTCH;

        //Open New Dutch Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice() - 1;

        //place first bid on the auction
        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__BidTooLow.selector);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();
    }

    function testIfPlaceBidRevertDueToFailedRefund() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.ENGLISH;

        //Open New English Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);

        AuctionStruct memory auction = yoyoAuction.getAuctionFromAuctionId(1);

        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() + yoyoAuction.getMinimumBidChangeAmount();
        //Mock contract that will revert refund place a bid and become new higher bidder
        ConstructorParams memory params = ConstructorParams({
            baseURI: 'https://example.com/api/metadata/',
            auctionContract: address(yoyoAuction),
            basicMintPrice: 0.01 ether
        });
        RevertOnReceiverMock revertOnReceiverMock = new RevertOnReceiverMock(params);
        revertOnReceiverMock.payAuctionContract{ value: newBidPlaced }(
            payable(address(yoyoAuction)),
            auction.auctionId
        );

        //Place a new bid with user and try to refund the previous bidder
        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__PreviousBidderRefundFailed.selector);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced * 2 }(1);
    }

    //Test Close Auction Function
    function testIfCloseAuctionWorksWithDutchAuctionAndMintNft() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;

        //Open New Dutch Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        uint256 startTime = block.timestamp;
        uint256 startPrice = yoyoAuction.getCurrentAuctionPrice();
        vm.stopPrank();

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(1).endTime - 4 hours);
        uint256 newBidPlaced = yoyoAuction.getCurrentAuctionPrice();

        //Place a bid on the auction
        vm.startPrank(USER_1);
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(1, tokenId, startPrice, startTime, block.timestamp, USER_1, newBidPlaced);
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__AuctionFinalized(1, tokenId, USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        vm.roll(block.number + 1);

        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.FINALIZED);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(tokenId), USER_1);
    }

    function testIfCloseAuctionWorksWithEnglishAuctionAndMintNft() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.ENGLISH;

        //Open New English Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        uint256 startTime = block.timestamp;
        uint256 startPrice = yoyoNft.getBasicMintPrice();
        vm.stopPrank();

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(1).endTime - 4 hours);
        uint256 newBidPlaced = yoyoNft.getBasicMintPrice() * 2;

        //Place a bid on the auction
        vm.startPrank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        vm.roll(block.number + 1);
        vm.warp(yoyoAuction.getAuctionFromAuctionId(1).endTime);
        //PerformUpkeep check conditions and call closeAuction function
        yoyoAuction.performUpkeep(abi.encode(1));

        assertTrue(yoyoAuction.getAuctionFromAuctionId(1).state == AuctionState.FINALIZED);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).startTime, startTime);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).startPrice, startPrice);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).endTime, block.timestamp);
        assertEq(yoyoAuction.getAuctionFromAuctionId(1).nftOwner, USER_1);
        assertEq(yoyoNft.ownerOf(tokenId), USER_1);
    }

    function testIfCloseAuctionFailMintWithoutErrorAndEmitEvents() public {
        //Deploy the mock contract
        YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
        //deploy new istance of YoyoAuction with the mock contract
        YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
        yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;

        yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

        //Set Mock to panic

        yoyoNftMockFailingMint.setShouldPanic(true);

        //Place a Bid and trigger close auction
        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            1,
            tokenId,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startPrice,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startTime,
            block.timestamp,
            USER_1,
            newBidPlaced
        );
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, 'unknown error');
        yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));
    }

    function testIfCloseAuctionFailMintWithErrorAndEmitEvents() public {
        //Deploy the mock contract
        YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
        //deploy new istance of YoyoAuction with the mock contract
        YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
        yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;

        yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

        //Set Mock to fail mint
        string memory reason = 'mint failed';
        yoyoNftMockFailingMint.setShouldFailMint(true, reason);

        //Place a Bid and trigger close auction
        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            1,
            tokenId,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startPrice,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startTime,
            block.timestamp,
            USER_1,
            newBidPlaced
        );
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, reason);
        yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));
    }

    //Test manual mint function
    function testIfManulaMintCatchErrorWithReasonWhenItFails() public {
        //Deploy the mock contract
        YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
        //deploy new istance of YoyoAuction with the mock contract
        YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
        yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;

        yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

        //Set Mock to fail mint
        string memory reason = 'mint failed';
        yoyoNftMockFailingMint.setShouldFailMint(true, reason);

        //Place a Bid and trigger close auction
        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
        vm.expectEmit(true, true, true, true);
        emit YoyoAuction__AuctionClosed(
            1,
            tokenId,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startPrice,
            yoyoAuctionWithMock.getAuctionFromAuctionId(1).startTime,
            block.timestamp,
            USER_1,
            newBidPlaced
        );
        //Auction is closed but mint fails
        yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));

        //Try to manually mint the NFT
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, reason);
        yoyoAuctionWithMock.manualMintForWinner(1);

        assertTrue(yoyoAuctionWithMock.getAuctionFromAuctionId(1).state == AuctionState.CLOSED);
        assertEq(yoyoAuctionWithMock.getAuctionFromAuctionId(1).nftOwner, address(0));
    }

    function testIfManulaMintCatchUnknownErrorWhenItFails() public {
        //Deploy the mock contract
        YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
        //deploy new istance of YoyoAuction with the mock contract
        YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
        yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

        //OpenNewAuction
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;
        yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

        //Set Mock to panic
        yoyoNftMockFailingMint.setShouldPanic(true);

        //Place a Bid and trigger close auction
        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
        yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        //Assert that the auction is closed but mint fails
        AuctionStruct memory currentAuction = yoyoAuctionWithMock.getAuctionFromAuctionId(1);
        assertTrue(currentAuction.state == AuctionState.CLOSED);
        assertEq(currentAuction.nftOwner, address(0));

        //Try to manually mint the NFT
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__MintFailedLog(1, tokenId, USER_1, 'unknown error');
        yoyoAuctionWithMock.manualMintForWinner(1);

        assertTrue(yoyoAuctionWithMock.getAuctionFromAuctionId(1).state == AuctionState.CLOSED);
        assertEq(yoyoAuctionWithMock.getAuctionFromAuctionId(1).nftOwner, address(0));
    }

    function testIfManualMintWorksAfterMintFailed() public {
        //Deploy the mock contract
        YoyoNftMockFailingMint yoyoNftMockFailingMint = new YoyoNftMockFailingMint();
        YoyoAuction yoyoAuctionWithMock = new YoyoAuction();
        yoyoAuctionWithMock.setNftContract(address(yoyoNftMockFailingMint));

        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;
        yoyoAuctionWithMock.openNewAuction(tokenId, auctionType);

        string memory reason = 'mint failed';
        yoyoNftMockFailingMint.setShouldFailMint(true, reason);

        vm.startPrank(USER_1);
        uint256 newBidPlaced = yoyoAuctionWithMock.getCurrentAuctionPrice();
        yoyoAuctionWithMock.placeBidOnAuction{ value: newBidPlaced }(1);
        vm.stopPrank();

        assertTrue(yoyoAuctionWithMock.getAuctionFromAuctionId(1).state == AuctionState.CLOSED);

        yoyoNftMockFailingMint.setShouldFailMint(false, '');
        yoyoNftMockFailingMint.resetToken(tokenId);
        vm.roll(block.number + 1);
        vm.expectEmit(true, true, true, false);
        emit YoyoAuction__AuctionFinalized(1, tokenId, USER_1);
        yoyoAuctionWithMock.manualMintForWinner(1);
        assertTrue(yoyoAuctionWithMock.getAuctionFromAuctionId(1).state == AuctionState.FINALIZED);
        assertEq(yoyoAuctionWithMock.getAuctionFromAuctionId(1).nftOwner, USER_1);
    }

    function testIfManualMintRevertsIfNftContractNotSet() public {
        YoyoAuction yoyoAuctionWithoutNft = new YoyoAuction();

        vm.expectRevert(YoyoAuction__NftContractNotSet.selector);
        yoyoAuctionWithoutNft.manualMintForWinner(1);
    }

    function testIfManualMintRevertsIfNotOwner() public {
        vm.startPrank(USER_2);
        vm.expectRevert(YoyoAuction__NotOwner.selector);
        yoyoAuction.manualMintForWinner(1);
        vm.stopPrank();
    }

    function testIfManulaMintRevertsIfAuctionNotClosed() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;
        //Open New Dutch Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);

        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__InvalidTokenId.selector);
        yoyoAuction.manualMintForWinner(1);
        vm.stopPrank();
    }

    function testIfManualMintRevertsDueToNftOwnerAlreadySet() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;

        //Open New Dutch Auction
        vm.prank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        uint256 bidAmount = yoyoAuction.getAuctionFromAuctionId(1).startPrice;

        //Place a bid to close the auction
        vm.prank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: bidAmount }(1);

        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__InvalidTokenId.selector);
        yoyoAuction.manualMintForWinner(1);
        vm.stopPrank();
    }

    //Test Change Mint Price
    function testIfChangeMintPriceRevertsIfNotOwner() public {
        uint256 newPrice = 0.1 ether;
        vm.startPrank(USER_1);
        vm.expectRevert(YoyoAuction__NotOwner.selector);
        yoyoAuction.changeMintPrice(newPrice);
        vm.stopPrank();
    }

    function testIfChangeMintPriceRevertsDueToNftContractNotSet() public {
        uint256 newPrice = 0.1 ether;
        vm.startPrank(deployer);
        YoyoAuction yoyoAuctionWithoutNft = new YoyoAuction();

        vm.expectRevert(YoyoAuction__NftContractNotSet.selector);
        yoyoAuctionWithoutNft.changeMintPrice(newPrice);
        vm.stopPrank();
    }

    function testIfChangeMintPriceRevertsDueToNewPirceEqualToZero() public {
        uint256 newPrice = 0;
        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__InvalidValue.selector);
        yoyoAuction.changeMintPrice(newPrice);
        vm.stopPrank();
    }

    function testIfChangeMintPriceRevertsWhileCurrentAuctionIsOpen() public {
        uint256 tokenId = 1;
        AuctionType auctionType = AuctionType.ENGLISH;
        uint256 newPrice = 0.1 ether;

        //Open New English Auction
        vm.startPrank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);
        vm.stopPrank();

        vm.startPrank(deployer);
        vm.expectRevert(YoyoAuction__CannotChangeMintPriceDuringOpenAuction.selector);
        yoyoAuction.changeMintPrice(newPrice);
        vm.stopPrank();
    }

    function testIfChangeMintPriceWorksWhileCurrentAuctionIsNotOpen() public {
        uint256 newPrice = 0.1 ether;
        vm.startPrank(deployer);
        yoyoAuction.changeMintPrice(newPrice);
        vm.stopPrank();

        assertEq(yoyoNft.getBasicMintPrice(), newPrice);
    }

    //Test getters

    function testGetNftContract() public {
        assertEq(yoyoAuction.getNftContract(), address(yoyoNft));
    }

    function testGetAuctionCounterInitiallyZero() public {
        assertEq(yoyoAuction.getAuctionCounter(), 0);
    }

    function testGetAuctionDurationInHours() public {
        assertEq(yoyoAuction.getAuctionDurationInHours(), 24 hours);
    }

    function testGetMinimumBidChangeAmount() public {
        uint256 basicMintPrice = yoyoNft.getBasicMintPrice();
        assertEq(yoyoAuction.getMinimumBidChangeAmount(), basicMintPrice / 40);
    }

    function testGetDutchAuctionStartPriceMultiplier() public {
        assertEq(yoyoAuction.getDutchAuctionStartPriceMultiplier(), 13);
    }

    function testGetAuctionFromAuctionIdReturnsEmpty() public {
        yoyoAuction.getAuctionFromAuctionId(0);
        assertTrue(yoyoAuction.getAuctionFromAuctionId(0).state == AuctionState.NOT_STARTED);
    }

    function testGetCurrentAuction() public {
        vm.prank(deployer);
        yoyoAuction.openNewAuction(5, AuctionType.ENGLISH);
        uint256 auctionCounter = yoyoAuction.getAuctionCounter();

        assertEq(yoyoAuction.getCurrentAuction().auctionId, auctionCounter);
    }

    function testIfGetCurrentAuctionPriceRevertsIfNoAuctionOpen() public {
        vm.expectRevert(YoyoAuction__AuctionNotOpen.selector);
        yoyoAuction.getCurrentAuctionPrice();
    }

    function testGetCurrentAuctionPriceOnEnglishAuction() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.ENGLISH;
        vm.prank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);

        uint256 minimumBidChangeAmountOfEnglishAuction = yoyoAuction.getAuctionFromAuctionId(1).minimumBidChangeAmount;
        uint256 bidPlaced = 1 ether;

        vm.prank(USER_1);
        yoyoAuction.placeBidOnAuction{ value: bidPlaced }(1);

        assertEq(yoyoAuction.getCurrentAuctionPrice(), bidPlaced + minimumBidChangeAmountOfEnglishAuction);
    }

    function testGetCurrentAuctionPriceOnDutchAuction() public {
        uint256 tokenId = 5;
        AuctionType auctionType = AuctionType.DUTCH;
        vm.prank(deployer);
        yoyoAuction.openNewAuction(tokenId, auctionType);

        uint256 startPrice = yoyoAuction.getAuctionFromAuctionId(1).startPrice;
        uint256 startTime = yoyoAuction.getAuctionFromAuctionId(1).startTime;
        uint256 endTime = yoyoAuction.getAuctionFromAuctionId(1).endTime;
        uint256 priceAtTheEnd = startPrice / yoyoAuction.getDutchAuctionStartPriceMultiplier();
        uint256 totalDrop = startPrice - priceAtTheEnd;

        vm.warp(startTime); // Warp to the start of the auction
        assertEq(yoyoAuction.getCurrentAuctionPrice(), startPrice);

        vm.warp(startTime + (endTime - startTime) / 2); // Warp to the middle of the auction
        uint256 currentAuctionPriceTest = startPrice - (totalDrop / 2);
        assertEq(yoyoAuction.getCurrentAuctionPrice(), currentAuctionPriceTest);

        vm.warp(endTime); // Warp to the end of the auction
        assertEq(yoyoAuction.getCurrentAuctionPrice(), priceAtTheEnd);
    }
}
