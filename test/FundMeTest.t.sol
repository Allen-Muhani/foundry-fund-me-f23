// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("user");

    FundMe i_fundMe;

    uint256 constant SEND_VALUE = 10 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        i_fundMe = deployer.run();

        vm.deal(USER, SEND_VALUE);
    }

    function testMinimumDollarIsFive() external view {
        assertEq(i_fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() external view {
        assertEq(i_fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() external view {
        uint256 version = i_fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() external {
        vm.expectRevert();
        i_fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() external funded {
        uint256 amountFunded = i_fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() external funded {
        address funder = i_fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        i_fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() external funded {
        vm.prank(USER);
        vm.expectRevert();
        i_fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() external funded {
        // Arrange
        uint256 startingOwnerBalance = i_fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(i_fundMe).balance;

        // Act
        vm.prank(i_fundMe.getOwner());
        i_fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = i_fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(i_fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawalFromMultipleFunders() public {
        // Arrange
        uint160 numberOfFunders = 10;

        for (uint160 i = 1; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            i_fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = i_fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(i_fundMe).balance;

        // Act
        vm.startPrank(i_fundMe.getOwner());
        i_fundMe.withdraw();
        vm.stopPrank();

        // Assert
        uint256 endingFundMeBalance = address(i_fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            i_fundMe.getOwner().balance
        );
    }
}
