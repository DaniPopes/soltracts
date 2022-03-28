// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Initializable } from "../proxy/utils/Initializable.sol";

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/ReentrancyGuard.sol)
abstract contract ReentrancyGuardUpgradeable is Initializable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when reentering `nonReentrant` functions.
    error Reentrancy();

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    uint256 private locked;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZER                                */
    /* -------------------------------------------------------------------------- */

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        locked = 1;
    }

    /* -------------------------------------------------------------------------- */
    /*                            ReentrancyGuard LOGIC                           */
    /* -------------------------------------------------------------------------- */

    /// @dev Prevents a contract from calling itself, directly or indirectly.
    /// Calling a `nonReentrant` function from another `nonReentrant`
    /// function is not supported. It is possible to prevent this from happening
    /// by making the `nonReentrant` function external, and making it call a
    /// `private` function that does the actual work.
    modifier nonReentrant() {
        if (locked != 1) revert Reentrancy();

        locked = 2;

        _;

        locked = 1;
    }
}
