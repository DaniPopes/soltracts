// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ERC721 } from "../ERC721.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Batch transfer extension for ERC721.
abstract contract ERC721Batch is ERC721 {
    /* -------------------------------------------------------------------------- */
    /*                              ERC721Batch LOGIC                             */
    /* -------------------------------------------------------------------------- */

    /// @notice Transfers `id` tokens from `from` to one `to` address.
    /// WARNING: Usage of this method is discouraged, use {batchSafeTransferFrom} whenever possible.
    /// @dev See {ERC721.transferFrom}.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param ids The token IDs to transfer.
    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids
    ) external virtual {
        unchecked {
            uint256 length = ids.length;
            for (uint256 i; i < length; i++) {
                transferFrom(from, to, ids[i]);
            }
        }
    }

    /// @notice Transfers `id` tokens from `from` to many `to` addresses.
    /// WARNING: Usage of this method is discouraged, use {batchSafeTransferFrom} whenever possible.
    /// @dev See {ERC721.transferFrom}.
    /// @param from The address to transfer from.
    /// @param to The addresses to transfer to.
    /// @param ids The token IDs to transfer.
    function batchTransferFrom(
        address from,
        address[] calldata to,
        uint256[] calldata ids
    ) external virtual {
        unchecked {
            uint256 length = ids.length;
            for (uint256 i; i < length; i++) {
                transferFrom(from, to[i], ids[i]);
            }
        }
    }

    /// @notice Safely transfers `id` tokens from `from` to one `to` address.
    /// @dev See {ERC721.safeTransferFrom}.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param ids The token IDs to transfer.
    /// @param data The data to callback with.
    function batchSafeTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        bytes calldata data
    ) external virtual {
        unchecked {
            uint256 length = ids.length;
            for (uint256 i; i < length; i++) {
                safeTransferFrom(from, to, ids[i], data);
            }
        }
    }

    /// @notice Safely transfers `id` tokens from `from` to many `to` addresses.
    /// @dev See {ERC721.safeTransferFrom}.
    /// @param from The address to transfer from.
    /// @param to The addresses to transfer to.
    /// @param ids The token IDs to transfer.
    /// @param data The data to callback with.
    function batchSafeTransferFrom(
        address from,
        address[] calldata to,
        uint256[] calldata ids,
        bytes calldata data
    ) external virtual {
        unchecked {
            uint256 length = ids.length;
            for (uint256 i; i < length; i++) {
                safeTransferFrom(from, to[i], ids[i], data);
            }
        }
    }
}
