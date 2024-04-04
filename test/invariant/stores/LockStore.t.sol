// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

struct Lock {
    uint256 amount;
    uint256 unlockTime;
    uint256 timestamp;
}

contract LockStore {
    mapping(address => Lock[]) public locks;

    constructor() {}

    function addLock(address account, uint256 amount, uint256 unlockTime, uint256 timestamp) external {
        locks[account].push(Lock(amount, unlockTime, timestamp));
    }

    function getLatestLock(address account) external view returns (Lock memory) {
        return locks[account][locks[account].length - 1];
    }

    function getLocks(address account) external view returns (Lock[] memory) {
        return locks[account];
    }
}
