// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/Initializable.sol)
abstract contract Initializable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when contract is not initializing.
    error NotInitializing();

    /// @dev Thrown when contract has already been initialized.
    error AlreadyInitialized();

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Indicates that the contract has been initialized.
    uint8 private _initialized;

    /// @dev Indicates that the contract is in the process of being initialized.
    bool private _initializing;

    /// @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
    /// `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
    /// contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
    /// used to initialize parent contracts.
    /// `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
    /// initialization step. This is essential to configure modules that are added through upgrades and that require
    /// initialization.
    /// Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
    /// a contract, executing them in the right order is up to the developer or operator.
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
    /// {initializer} and {reinitializer} modifiers, directly or indirectly.
    modifier onlyInitializing() {
        if (!_initializing) revert NotInitializing();
        _;
    }

    /// @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
    /// Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
    /// to any version. It is recommended to use this to lock implementation contracts that are designed to be called
    /// through proxies.
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            if (version != 1 || address(this).code.length != 0) revert AlreadyInitialized();
            return false;
        } else {
            if (_initialized >= version) revert AlreadyInitialized();
            _initialized = version;
            return true;
        }
    }
}
