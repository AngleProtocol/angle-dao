// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/// @title IveANGLE
/// @author Angle Core Team
/// @notice Interface for the `VeANGLE` contract
interface IveANGLE is IERC20Upgradeable {
    function set_emergency_withdrawal() external;
    function emergency_withdrawal() external view returns (bool);
    function withdraw_fast() external;
    function initialize(
        address admin,
        address token_addr,
        address smart_wallet_checker,
        string memory name,
        string memory symbol
    ) external;
}
