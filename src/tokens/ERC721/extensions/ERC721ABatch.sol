// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721A } from "../ERC721A.sol";

/// @notice Batch transfer extension for ERC721A.
/// @dev Implements
abstract contract ERC721ABatch is ERC721A {
	/// @notice Transfers `id` tokens from `from` to one `to` address.
	/// WARNING: Usage of this method is discouraged, use {batchSafeTransferFrom} whenever possible.
	/// @dev See {transferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to The address the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	function batchTransferFrom(
		address from,
		address to,
		uint256[] calldata ids
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			transferFrom(from, to, ids[i]);
		}
	}

	/// @notice Transfers `id` tokens from `from` to many `to` addresses.
	/// WARNING: Usage of this method is discouraged, use {batchSafeTransferFrom} whenever possible.
	/// @dev See {transferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to An array of the addresses the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	function batchTransferFrom(
		address from,
		address[] calldata to,
		uint256[] calldata ids
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			transferFrom(from, to[i], ids[i]);
		}
	}

	/// @notice Safely transfers `id` tokens from `from` to one `to` address.
	/// @dev See {safeTransferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to The address the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	function batchSafeTransferFrom(
		address from,
		address to,
		uint256[] calldata ids
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			safeTransferFrom(from, to, ids[i]);
		}
	}

	/// @notice Safely transfers `id` tokens from `from` to many `to` addresses.
	/// @dev See {safeTransferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to An array of the addresses the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	function batchSafeTransferFrom(
		address from,
		address[] calldata to,
		uint256[] calldata ids
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			safeTransferFrom(from, to[i], ids[i]);
		}
	}

	/// @notice Safely transfers `id` tokens from `from` to one `to` address.
	/// @dev See {safeTransferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to The address the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	/// @param data An array of calldatas to pass in the {ERC721TokenReceiver-onERC721Received} callback.
	function batchSafeTransferFrom(
		address from,
		address to,
		uint256[] calldata ids,
		bytes[] calldata data
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			safeTransferFrom(from, to, ids[i], data[i]);
		}
	}

	/// @notice Safely transfers `id` tokens from `from` to many `to` addresses.
	/// @dev See {safeTransferFrom}.
	/// @param from The address the token are being transferred from.
	/// @param to An array of the addresses the tokens are being transferred to.
	/// @param ids An array of the token IDs to be transferred.
	/// @param data An array of calldatas to pass in the {ERC721TokenReceiver-onERC721Received} callback.
	function batchSafeTransferFrom(
		address from,
		address[] calldata to,
		uint256[] calldata ids,
		bytes[] calldata data
	) public virtual {
		uint256 length = ids.length;
		for (uint256 i; i < length; i++) {
			safeTransferFrom(from, to[i], ids[i], data[i]);
		}
	}
}
