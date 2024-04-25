// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import { IveANGLE } from "contracts/interfaces/IVeANGLE.sol";
import { VyperDeployer } from "contracts/utils/VyperDeployer.sol";
import { ANGLE } from "contracts/dao/ANGLE.sol";
import "utils/src/CommonUtils.sol";

contract Fixture is Test, CommonUtils {
    VyperDeployer public vyperDeployer;

    IveANGLE public veANGLE;
    address public admin;
    ANGLE public Angle;
    address public checker;

    address public alice;
    address public bob;

    function setUp() public virtual {
        uint256 CHAIN_SOURCE = CHAIN_ETHEREUM;

        vyperDeployer = new VyperDeployer();
        veANGLE = IveANGLE(vyperDeployer.deployContract("contracts/dao/veANGLE.vy"));

        vm.createSelectFork("mainnet");
        IveANGLE forkedveANGLE = IveANGLE(_chainToContract(CHAIN_SOURCE, ContractType.veANGLE));

        admin = forkedveANGLE.admin();
        string memory name = forkedveANGLE.name();
        string memory symbol = forkedveANGLE.symbol();
        checker = forkedveANGLE.smart_wallet_checker();
        Angle = ANGLE(_chainToContract(CHAIN_SOURCE, ContractType.Angle));

        veANGLE.initialize(admin, address(Angle), checker, name, symbol);

        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }
}
