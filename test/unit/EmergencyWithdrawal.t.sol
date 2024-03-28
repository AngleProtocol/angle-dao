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

    function test_emergencyWithdrawal_SingleLock() external {
        deal(address(Angle), alice, 10e18);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), 10e18);
        veANGLE.create_lock(10e18, block.timestamp + 365 days);
        vm.stopPrank();

        assertEq(Angle.balanceOf(alice), 0);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.prank(alice, alice);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(alice), 10e18);
    }

    function test_emergencyWithdrawal_AfterLockExpired() external {
        deal(address(Angle), alice, 10e18);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), 10e18);
        veANGLE.create_lock(10e18, block.timestamp + 365 days);
        vm.stopPrank();

        assertEq(Angle.balanceOf(alice), 0);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.warp(block.timestamp + 365 days + 1);

        vm.prank(alice, alice);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(alice), 10e18);
    }

    function test_emergencyWithdrawal_MultipleLocks() external {
        deal(address(Angle), alice, 10e18);
        deal(address(Angle), bob, 20e18);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), 10e18);
        veANGLE.create_lock(10e18, block.timestamp + 365 days * 4);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);

        vm.startPrank(bob, bob);
        Angle.approve(address(veANGLE), 20e18);
        veANGLE.create_lock(20e18, block.timestamp + 365 days * 2);
        vm.stopPrank();

        assertEq(Angle.balanceOf(alice), 0);
        assertEq(Angle.balanceOf(bob), 0);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.prank(alice, alice);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(alice), 10e18);

        vm.warp(block.timestamp + 365 days);

        vm.prank(bob, bob);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(bob), 20e18);
    }

    function test_emergencyWithdrawal_CannotWithdrawTwice() external {
        deal(address(Angle), alice, 10e18);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), 10e18);
        veANGLE.create_lock(10e18, block.timestamp + 365 days);
        vm.stopPrank();

        assertEq(Angle.balanceOf(alice), 0);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        vm.prank(alice, alice);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(alice), 10e18);

        vm.prank(alice, alice);
        veANGLE.withdraw_fast();

        assertEq(Angle.balanceOf(alice), 10e18);
    }

    function test_emergencyWithdrawal_CannotWithdrawWhenNoEmergency() external {
        deal(address(Angle), alice, 20e18);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), 20e18);
        veANGLE.create_lock(10e18, block.timestamp + 365 days);
        vm.stopPrank();

        vm.expectRevert("Emergency withdrawal not enabled");
        veANGLE.withdraw_fast();
    }
}
