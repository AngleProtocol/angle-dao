// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Fixture, IveANGLE } from "../Fixture.t.sol";
import { console } from "forge-std/console.sol";

contract EmergencyWithdrawal is Fixture {
    function test_emergencyWithdrawal_Normal() external {
        assertEq(veANGLE.emergency_withdrawal(), false);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        assertEq(veANGLE.emergency_withdrawal(), true);
    }

    function test_emergencyWithdrawal_checkpoint() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.checkpoint();
    }

    function test_emergencyWithdrawal_create_lock() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.create_lock(10e18, block.timestamp + 365 days);
    }

    function test_emergencyWithdrawal_increase_amount() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.increase_amount(0);
    }

    function test_emergencyWithdrawal_increase_unlock_time() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.increase_unlock_time(block.timestamp + 365 days);
    }

    function test_emergencyWithdrawal_withdraw() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.withdraw();
    }

    function test_emergencyWithdrawal_deposit_for() external {
        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.expectRevert("Emergency withdrawal enabled");
        veANGLE.deposit_for(alice, 10e18);
    }
}
