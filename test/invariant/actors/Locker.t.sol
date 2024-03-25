// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./BaseActor.t.sol";
import { TimestampStore } from "../stores/TimestampStore.t.sol";
import { LockStore, Lock } from "../stores/LockStore.t.sol";
import { IveANGLE } from "../../../contracts/interfaces/IVeANGLE.sol";

contract Locker is BaseActor {
    IveANGLE public veANGLE;
    TimestampStore public timestampStore;
    LockStore public lockStore;
    IERC20 public angle;

    constructor(
        uint256 _nbrActor,
        IERC20 _angle,
        IveANGLE _veANGLE,
        TimestampStore _timestampStore,
        LockStore _lockStore
    ) BaseActor(_nbrActor, "Locker") {
        timestampStore = _timestampStore;
        lockStore = _lockStore;
        angle = _angle;
        veANGLE = _veANGLE;
    }

    function createLock(uint256 actorIndex, uint256 amount, uint256 duration) public useActor(actorIndex) {
        if (veANGLE.locked__end(_currentActor) != 0) {
            return;
        }
        duration = bound(duration, 1 weeks, 365 days * 4);
        amount = bound(amount, 1e18, 100e18);

        deal(address(angle), _currentActor, amount);
        angle.approve(address(veANGLE), amount);

        veANGLE.create_lock(amount, block.timestamp + duration);

        lockStore.addLock(_currentActor, amount, block.timestamp + duration, block.timestamp);

        // increase timestamp to avoid lock timestamp collision
        vm.warp(block.timestamp + 10);
        vm.roll(block.number + 1);
        timestampStore.increaseCurrentTimestamp(10);
    }

    function withdraw(uint256 actorIndex) public useActor(actorIndex) {
        if (veANGLE.locked__end(_currentActor) != 0 && veANGLE.locked__end(_currentActor) < block.timestamp) {
            veANGLE.withdraw();
            lockStore.addLock(_currentActor, 0, 0, block.timestamp);

            // increase timestamp to avoid lock timestamp collision
            vm.warp(block.timestamp + 10);
            vm.roll(block.number + 1);
            timestampStore.increaseCurrentTimestamp(10);
        }
    }

    function extendLockTime(uint256 actorIndex, uint256 duration) public useActor(actorIndex) {
        uint256 end = veANGLE.locked__end(_currentActor);
        if (end == 0 || end < block.timestamp || end + 1 weeks > block.timestamp + 365 days * 4) {
            return;
        }

        duration = bound(duration, end + 1 weeks, block.timestamp + 365 days * 4);
        veANGLE.increase_unlock_time(duration);

        IveANGLE.LockedBalance memory locked = veANGLE.locked(_currentActor);

        lockStore.addLock(_currentActor, locked.amount, duration, block.timestamp);

        // increase timestamp to avoid lock timestamp collision
        vm.warp(block.timestamp + 10);
        vm.roll(block.number + 1);
        timestampStore.increaseCurrentTimestamp(10);
    }

    function extendLockAmount(uint256 actorIndex, uint256 amount) public useActor(actorIndex) {
        if (veANGLE.balanceOf(_currentActor) == 0) {
            return;
        }
        amount = bound(amount, 1e18, 100e18);

        IveANGLE.LockedBalance memory locked = veANGLE.locked(_currentActor);

        deal(address(angle), _currentActor, amount);
        angle.approve(address(veANGLE), amount);
        veANGLE.increase_amount(amount);

        Lock memory lastLock = lockStore.getLatestLock(_currentActor);

        lockStore.addLock(_currentActor, locked.amount + amount, locked.end, block.timestamp, lastLock.start);

        // increase timestamp to avoid lock timestamp collision
        vm.warp(block.timestamp + 10);
        vm.roll(block.number + 1);
        timestampStore.increaseCurrentTimestamp(10);
    }
}
