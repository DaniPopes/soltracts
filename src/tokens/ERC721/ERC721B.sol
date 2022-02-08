// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

import { ERC721 } from "./ERC721.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Refactored from beskay/ERC721B (https://github.com/beskay/ERC721B).
/// @dev Includes better NATSPEC, shorter error strings, further gas optimizations.
/// Updated, minimalist and gas efficient version of OpenZeppelins ERC721 contract.
/// Includes the Metadata and Enumerable extension.
/// Assumes serials are sequentially minted starting at 0 (e.g. 0, 1, 2, 3..).
/// Does not support burning tokens to address(0).
abstract contract ERC721B is ERC721 {
	/* -------------------------------------------------------------------------- */
	/*                               ERC721B STORAGE                              */
	/* -------------------------------------------------------------------------- */

	/// @dev Array which maps token ID to address (index is id).
	address[] internal _owners;

	/* -------------------------------------------------------------------------- */
	/*                                 CONSTRUCTOR                                */
	/* -------------------------------------------------------------------------- */

	constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

	/* -------------------------------------------------------------------------- */
	/*                              ENUMERABLE LOGIC                              */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the total amount of tokens stored by the contract.
	/// @return The token supply.
	function totalSupply() public view override returns (uint256) {
		return _owners.length;
	}

	/// @notice Returns a token ID owned by `owner` at a given `index` of its token list.
	/// @dev Use along with {balanceOf} to enumerate all of `owner`"s tokens.
	/// Dont call this function on chain from another smart contract, since it can become quite expensive
	/// @param owner The address to query.
	/// @param index The index to query.
	/// @return The token ID.
	function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
		require(index < balanceOf(owner), "INVALID_INDEX");

		uint256 count;
		uint256 length = _owners.length;
		for (uint256 i; i < length; i++) {
			if (owner == ownerOf(i)) {
				if (count == index) return i;
				else count++;
			}
		}

		revert("NOT_FOUND");
	}

	/// @notice Returns a token ID at a given `index` of all the tokens stored by the contract.
	/// @dev Use along with {totalSupply} to enumerate all tokens.
	/// @param index The index to query.
	/// @return The token ID.
	function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
		require(index < _owners.length, "INVALID_INDEX");
		return index;
	}

	/* -------------------------------------------------------------------------- */
	/*                                ERC721 LOGIC                                */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the number of tokens in an account.
	/// @param owner The address to query.
	/// @dev Iterates through _owners array.
	/// It is not recommended to call this function from another smart contract
	/// as it can become quite expensive -- call this function off chain instead.
	/// @return The balance.
	function balanceOf(address owner) public view virtual override returns (uint256) {
		require(owner != address(0), "INVALID_OWNER");

		uint256 count;
		uint256 length = _owners.length;
		for (uint256 i; i < length; i++) {
			if (owner == ownerOf(i)) {
				unchecked {
					count++;
				}
			}
		}
		return count;
	}

	/// @notice Returns the owner of a token ID.
	/// @dev Requirements:
	/// - `id` must exist.
	/// @param id The token ID.
	function ownerOf(uint256 id) public view virtual override returns (address) {
		require(_exists(id), "NONEXISTENT_TOKEN");

		for (uint256 i = id; ; i++) {
			if (_owners[i] != address(0)) {
				return _owners[i];
			}
		}

		revert("NOT_FOUND");
	}

	/* -------------------------------------------------------------------------- */
	/*                               INTERNAL LOGIC                               */
	/* -------------------------------------------------------------------------- */

	function _mint(address to, uint256 amount) internal virtual override {
		require(to != address(0), "INVALID_RECIPIENT");
		require(amount != 0, "INVALID_AMOUNT");

		// Counter or mint amount overflow is incredibly unrealistic.
		unchecked {
			uint256 _currentIndex = _owners.length;

			for (uint256 i = 0; i < amount - 1; i++) {
				_owners.push();
				emit Transfer(address(0), to, _currentIndex + i);
			}

			// set last index to receiver
			_owners.push(to);
			emit Transfer(address(0), to, _currentIndex + (amount - 1));
		}
	}

	function _exists(uint256 id) internal view virtual override returns (bool) {
		return id < _owners.length;
	}

	function _transfer(
		address from,
		address to,
		uint256 id
	) internal virtual override {
		require(ownerOf(id) == from, "WRONG_FROM");
		require(to != address(0), "INVALID_RECIPIENT");
		require(msg.sender == from || getApproved(id) == msg.sender || isApprovedForAll(from, msg.sender), "NOT_AUTHORIZED");

		// Clear approvals
		delete _tokenApprovals[id];

		// Set new owner
		_owners[id] = to;

		// if token ID below transferred one isn't set, set it to previous owner
		// if tokenid is zero, skip this to prevent underflow
		if (id != 0) {
			unchecked {
				uint256 prevId = id - 1;
				if (_owners[prevId] == address(0)) {
					_owners[prevId] = from;
				}
			}
		}

		emit Transfer(from, to, id);
	}
}