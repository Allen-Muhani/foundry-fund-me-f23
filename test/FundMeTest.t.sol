// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe i_fundMe;

    function setUp() external {
        FundMe fundMe = new FundMe();
        i_fundMe = fundMe;
    }

    function testMinimumDollarIsFive() external {
        assertEq(i_fundMe.MINIMUM_USD(), 5e18);
    }


    function testOwnerIsMsgSender() external {
        assertEq(i_fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() external {
        uint256 version = i_fundMe.getVersion();
        assertEq(version, 4);
    }
}
