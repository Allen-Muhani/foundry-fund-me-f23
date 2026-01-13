// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InterationsTest is Test {
    address USER = makeAddr("user");

    FundMe i_fundMe;

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        i_fundMe = deployer.run();

        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() external {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(i_fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(i_fundMe));

        assertEq(address(i_fundMe).balance, 0);
    }
}
