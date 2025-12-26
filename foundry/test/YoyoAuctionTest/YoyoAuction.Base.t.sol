// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test, console2, console } from 'forge-std/Test.sol';
import { DeployYoyoAuctionAndYoyoNft } from '../../script/DeployYoyoAuctionAndYoyoNft.s.sol';
import { HelperConfig } from '../../script/HelperConfig.sol';
import { YoyoAuction } from '../../src/YoyoAuction/YoyoAuction.sol';
import { YoyoNft } from '../../src/YoyoNft/YoyoNft.sol';
import { AuctionType, AuctionState } from '../../src/YoyoTypes.sol';
import { EthAndNftRefuseMock } from '../Mocks/EthAndNftRefuseMock.sol';

contract YoyoAuctionBaseTest is Test {
    YoyoAuction public yoyoAuction;
    YoyoNft public yoyoNft;
    HelperConfig public helperConfig;
    EthAndNftRefuseMock public ethAndNftRefuseMock;

    //Test Partecipants
    address public deployer;
    address public keeperMock; // Chainlink Automation mock for tests
    address public USER_1 = makeAddr('User1');
    address public USER_2 = makeAddr('User2');
    address public USER_NO_BALANCE = makeAddr('user no balance');

    uint256 public constant STARTING_BALANCE_YOYO_CONTRACT = 10 ether;
    uint256 public constant STARTING_BALANCE_AUCTION_CONTRACT = 10 ether;
    uint256 public constant STARTING_BALANCE_DEPLOYER = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_1 = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_2 = 10 ether;
    uint256 public constant STARTING_BALANCE_USER_NO_BALANCE = 0 ether;

    // Helper Constants
    uint256 constant VALID_TOKEN_ID = 5;
    uint256 public invalidTokenId; // Inizializzato nel setUp()
    AuctionType constant ENGLISH_TYPE = AuctionType.ENGLISH;
    AuctionType constant DUTCH_TYPE = AuctionType.DUTCH;

    function setUp() public {
        DeployYoyoAuctionAndYoyoNft deployerScript = new DeployYoyoAuctionAndYoyoNft();
        (yoyoAuction, yoyoNft, deployer, helperConfig) = deployerScript.run();

        ethAndNftRefuseMock = new EthAndNftRefuseMock(address(yoyoAuction));

        // Get keeperMock from YoyoAuction contract
        keeperMock = address(yoyoAuction.i_registry());

        // Initialize invalidTokenId after yoyoNft is set
        invalidTokenId = yoyoNft.MAX_NFT_SUPPLY() + 10;

        //Set up balances for each address
        vm.deal(deployer, STARTING_BALANCE_DEPLOYER);
        vm.deal(address(yoyoNft), STARTING_BALANCE_YOYO_CONTRACT);
        vm.deal(address(yoyoAuction), STARTING_BALANCE_AUCTION_CONTRACT);
        vm.deal(USER_1, STARTING_BALANCE_USER_1);
        vm.deal(USER_2, STARTING_BALANCE_USER_2);
        vm.deal(USER_NO_BALANCE, STARTING_BALANCE_USER_NO_BALANCE);
    }

    // Helper Functions
    function openEnglishAuctionHelper() internal returns (uint256) {
        vm.startPrank(deployer);
        uint256 auctionid = yoyoAuction.openNewAuction(VALID_TOKEN_ID, ENGLISH_TYPE);
        vm.stopPrank();
        return auctionid;
    }

    function openDutchAuctionHelper() internal returns (uint256) {
        vm.startPrank(deployer);
        uint256 auctionid = yoyoAuction.openNewAuction(VALID_TOKEN_ID, DUTCH_TYPE);
        vm.stopPrank();
        return auctionid;
    }

    function placeBidHelper(uint256 _auctionId, address _bidder, uint256 _bidAmount) internal {
        vm.startPrank(_bidder);
        yoyoAuction.placeBidOnAuction{ value: _bidAmount }(_auctionId);
        vm.stopPrank();
    }
}
