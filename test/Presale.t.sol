// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import "../src/Presale.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract PresaleTest is Test {
    Presale public presale;
    MockToken public saleToken;
    address public aggregator;

    // USDT ADRESS 
    address public constant USDT_ADRESS = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    // USDC ADRESS
    address public constant USDC_ADRESS = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    // ETH USD FEED
    address public constant ETH_USD_FEED = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    // Arbitrum mainnet addresses
    address constant ARBITRUM_USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address constant ARBITRUM_USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address constant ARBITRUM_ETH_USD_FEED = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    address public owner = vm.addr(0);
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    address public fundsReceiver = vm.addr(3);
    uint256[][3] public _phases;


    uint256 public constant ETH_PRICE = 2000 * 1e8; // $2000 per ETH
    uint256 public constant MAX_SELLING_AMOUNT = 1000000 * 1e18; // 1M tokens

    function setUp() public {
        // Create a fork of Arbitrum mainnet
        vm.createSelectFork("https://arb1.arbitrum.io/rpc");

        vm.startPrank(owner);

        // Deploy mock tokens
        usdt = new MockToken("USDT", "USDT");
        usdc = new MockToken("USDC", "USDC");
        saleToken = new MockToken("SALE", "SALE");

        // Initialize phases
       _phases = [
            [10_000_000 * 1e18, 0.005 * 1e6, block.timestamp + 1000],
            [10_000_000 * 1e18, 0.05 * 1e6, block.timestamp + 1000],
            [10_000_000 * 1e18, 0.5 * 1e6, block.timestamp + 1000]
        ];

        // Deploy presale contract
        presale = new Presale(
            address(usdt),
            address(usdc),
            address(saleToken),
            ARBITRUM_ETH_USD_FEED,
            _phases,
            MAX_SELLING_AMOUNT,
            fundsReceiver,
            block.timestamp,
            block.timestamp + 3 days
        );

        // Transfer sale tokens to presale contract
        saleToken.transfer(address(presale), MAX_SELLING_AMOUNT);

        vm.stopPrank();
    }

    function test_InitialSetup() public view {
        assertEq(presale.currentPhase(), 0);
        assertEq(presale.totalSold(), 0);
        assertEq(presale.maxSellingAmount(), MAX_SELLING_AMOUNT);
        assertEq(presale.tokenAdress(), address(saleToken));
    }

    function test_BuyTokensWithUSDT() public {
        vm.startPrank(user1);
        uint256 amount = 100 * 1e6; // 100 USDT
        usdt.approve(address(presale), amount);
        presale.buyTokensERC20(address(usdt), amount);

        uint256 expectedTokens = amount * 1e6 / 1e6; // Phase 1 price is 1
        assertEq(presale.userTokenBalance(user1), expectedTokens);
        assertEq(presale.totalSold(), expectedTokens);
        vm.stopPrank();
    }

    function test_BuyTokensWithETH() public {
        vm.startPrank(user1);
        uint256 ethAmount = 1 ether;
        presale.buyTokensEth{value: ethAmount}();

        uint256 expectedTokens = (ethAmount * ETH_PRICE / 1e18) * 1e6 / 1e6; // Phase 1 price is 1
        assertEq(presale.userTokenBalance(user1), expectedTokens);
        assertEq(presale.totalSold(), expectedTokens);
        vm.stopPrank();
    }

    function test_PhaseTransition() public {
        vm.startPrank(user1);
        uint256 amount = 300000 * 1e6; // 300k USDT to fill phase 1
        usdt.approve(address(presale), amount);
        presale.buyTokensERC20(address(usdt), amount);

        assertEq(presale.currentPhase(), 1);
        vm.stopPrank();
    }

    function test_Blacklist() public {
        vm.startPrank(owner);
        presale.addToBlacklist(user1);
        assertTrue(presale.isBlacklisted(user1));

        presale.removeFromBlacklist(user1);
        assertFalse(presale.isBlacklisted(user1));
        vm.stopPrank();
    }

    function test_BlacklistedUserCannotBuy() public {
        vm.startPrank(owner);
        presale.addToBlacklist(user1);
        vm.stopPrank();

        vm.startPrank(user1);
        uint256 amount = 100 * 1e6;
        usdt.approve(address(presale), amount);
        vm.expectRevert("User is blacklisted");
        presale.buyTokensERC20(address(usdt), amount);
        vm.stopPrank();
    }

    function test_ClaimTokens() public {
        // First buy some tokens
        vm.startPrank(user1);
        uint256 amount = 100 * 1e6;
        usdt.approve(address(presale), amount);
        presale.buyTokensERC20(address(usdt), amount);
        vm.stopPrank();

        // Fast forward past end time
        vm.warp(block.timestamp + 4 days);

        // Claim tokens
        vm.startPrank(user1);
        uint256 balanceBefore = saleToken.balanceOf(user1);
        presale.claimTokens();
        uint256 balanceAfter = saleToken.balanceOf(user1);
        assertEq(balanceAfter - balanceBefore, presale.userTokenBalance(user1));
        vm.stopPrank();
    }

    function test_EmergencyWithdraw() public {
        // First buy some tokens
        vm.startPrank(user1);
        uint256 amount = 100 * 1e6;
        usdt.approve(address(presale), amount);
        presale.buyTokensERC20(address(usdt), amount);
        vm.stopPrank();

        // Emergency withdraw
        vm.startPrank(owner);
        uint256 balanceBefore = saleToken.balanceOf(owner);
        presale.emergencyWithdrawERC20(address(saleToken), amount);
        uint256 balanceAfter = saleToken.balanceOf(owner);
        assertEq(balanceAfter - balanceBefore, amount);
        vm.stopPrank();
    }

    
    
}
