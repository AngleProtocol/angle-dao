// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Fixture, IveANGLE } from "../Fixture.t.sol";
import { console } from "forge-std/console.sol";

contract BalanceOf is Fixture {
    function test_balanceOf_LocksAfterTimestamp() external {
        uint256 timestamp = block.timestamp + 365 days * 2;
        uint256 oldTimestamp = block.timestamp;
        uint256 amount = 10e18;

        deal(address(Angle), alice, amount);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount);
        veANGLE.create_lock(amount, timestamp);
        vm.stopPrank();

        vm.warp(block.timestamp + 200 days);

        assertEq(veANGLE.balanceOf(alice, oldTimestamp - 1), 0);
    }

    function test_balanceOf_ExtendDate() external {
        uint256 timestamp = block.timestamp + 365 days * 2;
        uint256 oldTimestamp = block.timestamp;
        uint256 amount = 10e18;

        deal(address(Angle), alice, amount);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount);
        veANGLE.create_lock(amount, timestamp);
        vm.stopPrank();

        vm.warp(block.timestamp + 200 days);

        vm.prank(alice, alice);
        veANGLE.increase_unlock_time(block.timestamp + 4 * 365 days);

        assertGt(veANGLE.balanceOf(alice, block.timestamp), ((amount * 10000) * 95) / 1000000);
        assertLt(veANGLE.balanceOf(alice, block.timestamp), amount);

        assertGt(veANGLE.balanceOf(alice, oldTimestamp), ((amount * 10000) * 47) / 1000000);
        assertLt(veANGLE.balanceOf(alice, oldTimestamp), amount);
    }

    function test_balanceOf_ExtendAmount() external {
        uint256 timestamp = block.timestamp + 365 days * 2;
        uint256 oldTimestamp = block.timestamp;
        uint256 amount = 10e18;
        uint256 amount2 = 10e18;

        deal(address(Angle), alice, amount + amount2);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount);
        veANGLE.create_lock(amount, timestamp);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount2);
        veANGLE.increase_amount(amount2);
        vm.stopPrank();

        assertGt(veANGLE.balanceOf(alice, block.timestamp), (((amount + amount2) * 10000) * 22) / 1000000);
        assertLt(veANGLE.balanceOf(alice, block.timestamp), amount + amount2);

        assertGt(veANGLE.balanceOf(alice, oldTimestamp), ((amount * 10000) * 47) / 1000000);
        assertLt(veANGLE.balanceOf(alice, oldTimestamp), amount);
    }

    function test_balanceOf_LocksBeforeTimestamp() external {
        uint256 timestamp = block.timestamp + 365 days * 2;
        uint256 oldTimestamp = block.timestamp;
        uint256 amount = 10e18;

        deal(address(Angle), alice, amount);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount);
        veANGLE.create_lock(amount, timestamp);
        vm.stopPrank();

        assertGt(veANGLE.balanceOf(alice, block.timestamp), ((amount * 10000) * 47) / 1000000);
        assertLt(veANGLE.balanceOf(alice, block.timestamp), amount);
    }

    function test_balanceOf_MultipleLocks() external {
        uint256 timestamp = block.timestamp + 365 days * 2;
        uint256 oldTimestamp = block.timestamp;
        uint256 amount = 10e18;
        uint256 amount2 = 100e18;

        deal(address(Angle), alice, amount);

        vm.startPrank(alice, alice);
        Angle.approve(address(veANGLE), amount);
        veANGLE.create_lock(amount, timestamp);
        vm.stopPrank();

        vm.warp(block.timestamp + 365 days * 2 + 1);

        deal(address(Angle), alice, amount2);

        vm.startPrank(alice, alice);
        veANGLE.withdraw();
        Angle.approve(address(veANGLE), amount2);
        veANGLE.create_lock(amount2, block.timestamp + 365 days * 2);
        vm.stopPrank();

        assertGt(veANGLE.balanceOf(alice, block.timestamp), ((amount2 * 10000) * 47) / 1000000);
        assertLt(veANGLE.balanceOf(alice, block.timestamp), amount2);

        assertGt(veANGLE.balanceOf(alice, oldTimestamp), ((amount * 10000) * 47) / 1000000);
        assertLt(veANGLE.balanceOf(alice, oldTimestamp), amount);
    }
}
