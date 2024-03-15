// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import { IveANGLE } from "contracts/interfaces/IVeANGLE.sol";
import { VyperDeployer } from "contracts/utils/VyperDeployer.sol";
import { CommonUtils } from "utils/src/CommonUtils.sol";

contract Fixture is Test, CommonUtils {
    VyperDeployer public vyperDeployer;

    IveANGLE public veANGLE;

    function setUp() public {
        vm.createSelectFork("mainnet");

        vyperDeployer = new VyperDeployer();

        veANGLE = IveANGLE(vyperDeployer.deployContract("contracts/dao/veANGLE.vy"));

        // TODO find the args to deploy
        // veANGLE.initialize();
    }
}
