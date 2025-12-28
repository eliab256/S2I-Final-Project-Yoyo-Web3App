// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { YoyoNftBaseTest } from '../YoyoNftTest/YoyoNft.Base.t.sol';
import '../../src/YoyoNft/YoyoNftErrors.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract YoyoNftGettersTest is YoyoNftBaseTest {
    /*//////////////////////////////////////////////////////////////
                Test getters functions
    //////////////////////////////////////////////////////////////*/
    function testTokenURIRevertsIfTokenIdDoesNotExist() public {
        vm.expectRevert(YoyoNft__TokenIdDoesNotExist.selector);
        yoyoNft.tokenURI(invalidTokenId);
    }

    function testTokenURIRevertsIfTokenIdNotMinted() public {
        vm.expectRevert(YoyoNft__NftNotMinted.selector);
        yoyoNft.tokenURI(VALID_TOKEN_ID);
    }

    function testTokenURIReturnsCorrectURI() public {
        address recipient = address(USER_2);
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(recipient, VALID_TOKEN_ID);

        string memory expectedURI = string(
            abi.encodePacked(BASE_URI_EXAMPLE, '/', Strings.toString(VALID_TOKEN_ID), '.json')
        );

        assertEq(yoyoNft.tokenURI(VALID_TOKEN_ID), expectedURI);
    }

    function testGetBaseURI() public {
        assertEq(yoyoNft.getBaseURI(), BASE_URI_EXAMPLE);
    }

    function testGetTotalMinted() public {
        assertEq(yoyoNft.getTotalMinted(), 0);

        address recipient = address(USER_2);
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(recipient, VALID_TOKEN_ID);

        assertEq(yoyoNft.getTotalMinted(), 1);
    }

    function testGetOwnerFromTokenId() public {
        address recipient = address(USER_2);
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(recipient, VALID_TOKEN_ID);

        assertEq(yoyoNft.getOwnerFromTokenId(VALID_TOKEN_ID), recipient);
    }

    function testGetAccountBalance() public {
        assertEq(yoyoNft.getAccountBalance(USER_1), 0);

        address recipient = address(USER_1);
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(recipient, VALID_TOKEN_ID);

        assertEq(yoyoNft.getAccountBalance(USER_1), 1);
    }

    function testGetAuctionContract() public {
        assertEq(yoyoNft.getAuctionContract(), AUCTION_CONTRACT);
    }

    function testGetBasicMintPrice() public {
        uint256 newPrice = 0.003 ether;
        vm.prank(yoyoNft.getAuctionContract());
        yoyoNft.setBasicMintPrice(newPrice);
        assertEq(yoyoNft.getBasicMintPrice(), newPrice);
    }

    function testIfGetIfTokenIdIsMintableReturnTrueIfMintable() public {
        assertEq(yoyoNft.getIfTokenIdIsMintable(VALID_TOKEN_ID), true);
    }

    function testIfGetIfTokenIdIsMintableReturnFalseIfTokenAlreadyMinted() public {
        address recipient = address(USER_2);
        uint256 mintPrice = yoyoNft.getBasicMintPrice();

        // Mint the NFT first
        vm.prank(AUCTION_CONTRACT);
        yoyoNft.mintNft{ value: mintPrice }(recipient, VALID_TOKEN_ID);

        //Assert token five is not mintable
        assertEq(yoyoNft.getIfTokenIdIsMintable(VALID_TOKEN_ID), false);
    }

    function testIfGetIfTokenIdIsMintableReturnFalseIfTokenIdIsOutOfCollection() public {
        //Assert token five is not mintable
        assertEq(yoyoNft.getIfTokenIdIsMintable(invalidTokenId), false);
    }
}
