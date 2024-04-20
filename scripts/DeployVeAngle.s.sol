// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VyperDeployer } from "contracts/utils/VyperDeployer.sol";
import "./Utils.s.sol";

contract DeployVeAngleScript is Script, Utils, VyperDeployer {
    function run() external {
        uint256 deployerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC_MAINNET"), "m/44'/60'/0'/0/", 0);

        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address: ", deployer);

        vm.startBroadcast(deployerPrivateKey);
        address veANGLE = deployContract("contracts/dao/veANGLE.vy");
        vm.stopBroadcast();
        console.log("veANGLE deployed at: ", veANGLE);
    }
}
