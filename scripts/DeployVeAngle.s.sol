// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { VyperDeployer } from "contracts/utils/VyperDeployer.sol";
import "./Utils.s.sol";

contract DeployVeAngleScript is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.deriveKey(vm.envString("MNEMONIC_MAINNET"), "m/44'/60'/0'/0/", 0);
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer address: ", deployer);

        VyperDeployer vyperDeployer = new VyperDeployer();
        address veANGLE = vyperDeployer.deployContract("contracts/dao/veANGLE.vy");
        console.log("veANGLE deployed at: ", veANGLE);

        vm.stopBroadcast();
    }
}
