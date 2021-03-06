// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Minimal access control contract.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol)
abstract contract Ownable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when caller is not the owner.
    error NotOwner();

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Emitted when ownership is transferred using {transferOwnership}.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the address of the current owner.
    address public owner;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor() {
        _transferOwnership(address(0), msg.sender);
    }

    /* -------------------------------------------------------------------------- */
    /*                                Ownable LOGIC                               */
    /* -------------------------------------------------------------------------- */

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Transfers ownership of the contract to a new account (`_owner`).
    /// @param _owner The new owner.
    function transferOwnership(address _owner) public virtual onlyOwner {
        // onlyOwner -> msg.sender == owner
        _transferOwnership(msg.sender, _owner);
    }

    /// @dev Internal ownership transfer with no checks.
    /// Using `from` to save an SLOAD for emitting the event.
    function _transferOwnership(address from, address to) private {
        owner = to;
        emit OwnershipTransferred(from, to);
    }
}
