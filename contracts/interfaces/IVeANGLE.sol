// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

/// @title IveANGLE
/// @author Angle Core Team
/// @notice Interface for the `VeANGLE` contract
interface IveANGLE is IERC20MetadataUpgradeable {
    struct Point {
        int128 bias;
        int128 slope;
        uint256 ts;
        uint256 blk;
    }

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
    function admin() external view returns (address);
    function smart_wallet_checker() external view returns (address);
    function create_lock(uint256 value, uint256 unlock_time) external;
    function increase_amount(uint256 value) external;
    function increase_unlock_time(uint256 unlock_time) external;
    function initialized() external view returns (bool);
    function balanceOf(address addr, uint256 ts) external view returns (uint256);
    function find_user_timestamp_epoch(address addr, uint256 ts) external view returns (uint256);
    function user_point_history(address addr, uint256 idx) external view returns (Point memory);
}
