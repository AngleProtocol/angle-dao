// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import { Fixture, IveANGLE } from "../Fixture.t.sol";
import { console } from "forge-std/console.sol";

contract EmergencyWithdrawalFuzz is Fixture {
    function test_emergencyWithdrawalFuzz_Normal(uint256[10] memory balances, uint256[10] memory durations) external {
        address[] memory accounts = new address[](balances.length);
        for (uint i = 0; i < accounts.length; i++) {
            accounts[i] = address(uint160(uint256(keccak256(abi.encodePacked("account", i)))));
        }
        for (uint i = 0; i < accounts.length; i++) {
            durations[i] = bound(durations[i], 1 weeks, 365 days * 4);
            balances[i] = bound(balances[i], 1e18, 1e22);
            deal(address(Angle), accounts[i], balances[i]);

            vm.startPrank(accounts[i], accounts[i]);
            Angle.approve(address(veANGLE), balances[i]);
            veANGLE.create_lock(balances[i], block.timestamp + durations[i]);
            vm.stopPrank();
        }

        assertEq(veANGLE.emergency_withdrawal(), false);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        assertEq(veANGLE.emergency_withdrawal(), true);

        for (uint i = 0; i < accounts.length; i++) {
            assertEq(Angle.balanceOf(accounts[i]), 0);

            vm.prank(accounts[i]);
            veANGLE.withdraw_fast();
            assertEq(Angle.balanceOf(accounts[i]), balances[i]);

            vm.prank(accounts[i]);
            veANGLE.withdraw_fast();
            assertEq(Angle.balanceOf(accounts[i]), balances[i]);
        }
    }

    function test_emergencyWithdrawalFuzz_WithTimeWraps(
        uint256[10] memory balances,
        uint256[10] memory durations,
        uint256[10] memory timeWraps
    ) external {
        address[] memory accounts = new address[](balances.length);
        for (uint i = 0; i < accounts.length; i++) {
            accounts[i] = address(uint160(uint256(keccak256(abi.encodePacked("account", i)))));
        }

        for (uint i = 0; i < accounts.length; i++) {
            durations[i] = bound(durations[i], 1 weeks, 365 days * 4);
            balances[i] = bound(balances[i], 1e18, 1e22);
            deal(address(Angle), accounts[i], balances[i]);
            vm.startPrank(accounts[i], accounts[i]);
            Angle.approve(address(veANGLE), balances[i]);
            veANGLE.create_lock(balances[i], block.timestamp + durations[i]);
            vm.stopPrank();
        }

        assertEq(veANGLE.emergency_withdrawal(), false);

        vm.prank(admin);
        veANGLE.set_emergency_withdrawal();

        assertEq(veANGLE.emergency_withdrawal(), true);

        for (uint i = 0; i < accounts.length; i++) {
            timeWraps[i] = bound(timeWraps[i], 0, 365 days * 4 + 1);
            assertEq(Angle.balanceOf(accounts[i]), 0);

            vm.warp(block.timestamp + timeWraps[i]);

            vm.prank(accounts[i]);
            veANGLE.withdraw_fast();
            assertEq(Angle.balanceOf(accounts[i]), balances[i]);

            vm.prank(accounts[i]);
            veANGLE.withdraw_fast();
            assertEq(Angle.balanceOf(accounts[i]), balances[i]);
        }
    }
}
