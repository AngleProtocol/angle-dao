// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import { IERC20 } from "oz/token/ERC20/IERC20.sol";
import { Test, stdMath, StdStorage, stdStorage } from "forge-std/Test.sol";

contract BaseActor is Test {
    uint256 internal _minWallet = 0; // in base 18
    uint256 internal _maxWallet = 10 ** (18 + 12); // in base 18

    mapping(bytes32 => uint256) public calls;
    mapping(address => uint256) public addressToIndex;
    address[] public actors;
    uint256 public nbrActor;
    address internal _currentActor;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }

    modifier useActor(uint256 actorIndexSeed) {
        _currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
        vm.startPrank(_currentActor, _currentActor);
        _;
        vm.stopPrank();
    }

    constructor(uint256 _nbrActor, string memory actorType) {
        for (uint256 i; i < _nbrActor; ++i) {
            address actor = address(uint160(uint256(keccak256(abi.encodePacked("actor", actorType, i)))));
            actors.push(actor);
            addressToIndex[actor] = i;
        }
        nbrActor = _nbrActor;
    }
}
