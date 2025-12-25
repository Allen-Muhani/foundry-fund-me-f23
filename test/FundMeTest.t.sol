// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe i_fundMe;

    function setUp() external {

        DeployFundMe deployer = new DeployFundMe();
        i_fundMe = deployer.run();
    }

    function testMinimumDollarIsFive() view external {
        assertEq(i_fundMe.MINIMUM_USD(), 5e18);
    }


    function testOwnerIsMsgSender() view external {
        assertEq(i_fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() view external {
        uint256 version = i_fundMe.getVersion();
        assertEq(version, 4);
    }
}
