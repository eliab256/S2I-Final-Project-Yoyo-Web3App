// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoNftBaseTest } from '../YoyoNftTest/YoyoNft.Base.t.sol';
import '../../src/YoyoNft/YoyoNftErrors.sol';
import '../../src/YoyoNft/YoyoNftEvents.sol';

contract YoyoNftMintAndTransferTest is YoyoNftBaseTest {
    /*//////////////////////////////////////////////////////////////
                Test mint NFT function
    //////////////////////////////////////////////////////////////*/
    function testIfMintNftWorksAndEmitsEvent() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, VALID_TOKEN_ID);
        emit YoyoNft__NftMinted(USER_2, VALID_TOKEN_ID, yoyoNft.tokenURI(VALID_TOKEN_ID), block.timestamp);

        assertEq(yoyoNft.ownerOf(VALID_TOKEN_ID), USER_2);
    }

    function testIfMintNftUpdatesTotalMinted() public {
        uint256 secondTokenId = VALID_TOKEN_ID + 1;
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, VALID_TOKEN_ID);
        assertEq(yoyoNft.getTotalMinted(), 1);

        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, secondTokenId);
        assertEq(yoyoNft.getTotalMinted(), 2);
    }

    function testIfMintNftRevertsIfNotEnoughEthSent() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT);
        vm.expectRevert(YoyoNft__NotEnoughEtherSent.selector);
        yoyoNft.mintNft{ value: mintPrice - 0.00001 ether }(USER_2, VALID_TOKEN_ID);
    }

    function testIfMintNftRevertsIfNftIsAlreadyMinted() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT); //first mint
        yoyoNft.mintNft{ value: mintPrice }(USER_2, VALID_TOKEN_ID);

        vm.prank(AUCTION_CONTRACT); //try to mint again same tokenId
        vm.expectRevert(YoyoNft__NftAlreadyMinted.selector);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, VALID_TOKEN_ID);
    }

    function testIfNftMintRevertsIfRecipientIsZeroAddress() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT);
        vm.expectRevert(YoyoNft__InvalidAddress.selector);
        yoyoNft.mintNft{ value: mintPrice }(address(0), VALID_TOKEN_ID);
    }

    function testIfMintNftRevertsDueToInvalidTokenId() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        vm.prank(AUCTION_CONTRACT);
        vm.expectRevert(YoyoNft__TokenIdDoesNotExist.selector);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, invalidTokenId);
    }

    function testIfMintNftRevertsIfMaxSupplyReached() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();
        // Mint all NFTs to reach max supply
        for (uint256 i = 0; i < yoyoNft.MAX_NFT_SUPPLY(); i++) {
            vm.prank(AUCTION_CONTRACT);
            yoyoNft.mintNft{ value: mintPrice }(USER_1, i);
        }

        vm.expectRevert(YoyoNft__NftMaxSupplyReached.selector);
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_2, VALID_TOKEN_ID);
    }

    /*//////////////////////////////////////////////////////////////
                Test transfer NFT function
    //////////////////////////////////////////////////////////////*/
    function testIfTransferNftWorksAndEmitsEvent() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_1, VALID_TOKEN_ID);

        vm.prank(USER_1);
        yoyoNft.transferNft(USER_2, VALID_TOKEN_ID);

        assertEq(yoyoNft.ownerOf(VALID_TOKEN_ID), USER_2);
    }

    function testIfTransferNftRevertsIfToAddressIsZero() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_1, VALID_TOKEN_ID);

        vm.prank(USER_1);
        vm.expectRevert(YoyoNft__InvalidAddress.selector);
        yoyoNft.transferNft(address(0), VALID_TOKEN_ID);
    }

    function testIfTransferNftRevertsIfNotOwnerCallFunction() public {
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(USER_1, VALID_TOKEN_ID);
        vm.prank(USER_2);
        vm.expectRevert(YoyoNft__NotNftOwner.selector);
        yoyoNft.transferNft(USER_NO_BALANCE, VALID_TOKEN_ID);
    }
}
