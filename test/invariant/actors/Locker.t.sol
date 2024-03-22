// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./BaseActor.t.sol";
import { TimestampStore } from "../stores/TimestampStore.sol";
import { IveANGLE } from "../../../contracts/interfaces/IVeANGLE.sol";

contract Locker is BaseActor {
    IveANGLE public veANGLE;
    TimestampStore public timestampStore;
    IERC20 public angle;

    constructor(
        uint256 _nbrActor,
        IERC20 _angle,
        IveANGLE _veANGLE,
        TimestampStore _timestampStore
    ) BaseActor(_nbrActor, "Locker") {
        timestampStore = _timestampStore;
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
    }

    function withdraw(uint256 actorIndex) public useActor(actorIndex) {
        if (veANGLE.locked__end(_currentActor) != 0 && veANGLE.locked__end(_currentActor) < block.timestamp) {
            veANGLE.withdraw();
        }
    }

    function extendLockTime(uint256 actorIndex, uint256 duration) public useActor(actorIndex) {
        uint256 end = veANGLE.locked__end(_currentActor);
        if (end == 0 || end < block.timestamp || end + 1 weeks > block.timestamp + 365 days * 4) {
            return;
        }

        duration = bound(duration, end + 1 weeks, block.timestamp + 365 days * 4);
        veANGLE.increase_unlock_time(duration);
    }

    function extendLockAmount(uint256 actorIndex, uint256 amount) public useActor(actorIndex) {
        if (veANGLE.balanceOf(_currentActor) == 0) {
            return;
        }
        amount = bound(amount, 1e18, 100e18);

        deal(address(angle), _currentActor, amount);
        angle.approve(address(veANGLE), amount);
        veANGLE.increase_amount(amount);
    }
}
