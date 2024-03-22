// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

import "../Fixture.t.sol";
import { Locker } from "./actors/Locker.t.sol";
import { Param } from "./actors/Param.t.sol";
import { TimestampStore } from "./stores/TimestampStore.sol";
import { IERC20 } from "oz/token/ERC20/IERC20.sol";
import "oz/utils/Strings.sol";

//solhint-disable
import { console } from "forge-std/console.sol";

contract LocksInvariants is Fixture {
    uint256 internal constant _NUM_DELEGATORS = 10;
    uint256 internal constant _NUM_PARAMS = 1;

    Locker internal _lockerHandler;
    Param internal _paramHandler;
    TimestampStore internal _timestampStore;

    modifier useCurrentTimestampBlock() {
        vm.warp(_timestampStore.currentTimestamp());
        vm.roll(_timestampStore.currentBlockNumber());
        _;
    }

    function concat(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function setUp() public virtual override {
        super.setUp();

        _timestampStore = new TimestampStore();
        _lockerHandler = new Locker(_NUM_DELEGATORS, IERC20(address(Angle)), veANGLE, _timestampStore);
        _paramHandler = new Param(_NUM_PARAMS, _timestampStore);

        // Label newly created addresses
        for (uint256 i; i < _NUM_DELEGATORS; i++) {
            vm.label(_lockerHandler.actors(i), concat("Locker ", Strings.toString(i)));
        }
        vm.label({ account: address(_timestampStore), newLabel: "TimestampStore" });
        vm.label({ account: address(_paramHandler), newLabel: "Param" });

        targetContract(address(_lockerHandler));
        targetContract(address(_paramHandler));

        {
            bytes4[] memory selectors = new bytes4[](4);
            selectors[0] = Locker.createLock.selector;
            selectors[1] = Locker.withdraw.selector;
            selectors[2] = Locker.extendLockTime.selector;
            selectors[3] = Locker.extendLockAmount.selector;
            targetSelector(FuzzSelector({ addr: address(_lockerHandler), selectors: selectors }));
        }
        {
            bytes4[] memory selectors = new bytes4[](1);
            selectors[0] = Param.wrap.selector;
            targetSelector(FuzzSelector({ addr: address(_paramHandler), selectors: selectors }));
        }
    }

    function invariant_RightBalance() public useCurrentTimestampBlock {}
}
