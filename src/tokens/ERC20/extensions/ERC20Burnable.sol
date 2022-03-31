// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ERC20 } from "../ERC20.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol)
abstract contract ERC20Burnable is ERC20 {
    /* -------------------------------------------------------------------------- */
    /*                             ERC20Burnable LOGIC                            */
    /* -------------------------------------------------------------------------- */

    /// @notice Destroys `amount` tokens from the caller.
    /// @dev See {ERC20-_burn}.
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }

    /// @notice Destroys `amount` tokens from `account`, deducting from the caller's
    /// allowance.
    /// @dev Requirements:
    /// - the caller must have allowance for `accounts`'s tokens of at least
    /// `amount`.
    /// See {ERC20-_burn} and {ERC20-allowance}.
    function burnFrom(address from, uint256 amount) public virtual {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        _burn(from, amount);
    }
}
