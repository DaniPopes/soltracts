// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when calling `nonReentrant` functions with a callback.
    error Reentrancy();

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    uint256 private locked = 1;

    /* -------------------------------------------------------------------------- */
    /*                            ReentrancyGuard LOGIC                           */
    /* -------------------------------------------------------------------------- */

    modifier nonReentrant() {
        if (locked != 1) revert Reentrancy();

        locked = 2;

        _;

        locked = 1;
    }
}
