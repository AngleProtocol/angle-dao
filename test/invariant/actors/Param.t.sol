// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./BaseActor.t.sol";
import { TimestampStore } from "../stores/TimestampStore.sol";

contract Param is BaseActor {
    TimestampStore public timestampStore;

    constructor(uint256 _nbrActor, TimestampStore _timestampStore) BaseActor(_nbrActor, "Param") {
        timestampStore = _timestampStore;
    }

    function wrap(uint256 duration) public {
        duration = bound(duration, 0, 365 days * 5);
        timestampStore.increaseCurrentTimestamp(duration);
        vm.warp(timestampStore.currentTimestamp());
        vm.roll(timestampStore.currentBlockNumber());
    }
}
