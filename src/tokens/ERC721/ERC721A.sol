// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721 } from "./ERC721.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721) Non-Fungible Token Standard,
/// including the Metadata and Enumerable extension. Built to optimize for lowest gas possible during mints.
/// @dev Mix of ERC721 implementations by openzeppelin/openzeppelin-contracts, rari-capital/solmate
/// and chiru-labs/ERC721A with many additional optimizations.
/// Assumes serials are sequentially minted starting at 1 (e.g. 1, 2, 3, 4...).
/// Does not support burning tokens to address(0).
/// Missing function implementations:
/// - {tokenURI}.
abstract contract ERC721A is ERC721 {
	/* -------------------------------------------------------------------------- */
	/*                               ERC721A STORAGE                              */
	/* -------------------------------------------------------------------------- */

	/// @dev Values are packed in a 256 bits word.
	struct AddressData {
		uint128 balance;
		uint128 numberMinted;
	}

	/// @dev Values are packed in a 256 bits word.
	struct TokenOwnership {
		address owner;
		uint64 timestamp;
	}

	/// @dev A counter that increments for each minted token.
	/// Initialized to 1 to make all token ids (1 : `maxSupply`) instead of (0 : (`maxSupply` - 1)).
	/// Although `maxSupply` is not implemented, it is recommended in all contracts using this implementation.
	/// Initializing to 0 requires modifying {totalSupply}, {_exists} and {_idsOfOwner}.
	uint256 internal currentIndex = 1;

	/// @dev ID => {TokenOwnership}
	mapping(uint256 => TokenOwnership) internal _ownerships;

	/// @dev owner => {AddressData}
	mapping(address => AddressData) internal _addressData;

	/* -------------------------------------------------------------------------- */
	/*                                 CONSTRUCTOR                                */
	/* -------------------------------------------------------------------------- */

	/// @param name_ The collection name.
	/// @param symbol_ The collection symbol.
	constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

	/* -------------------------------------------------------------------------- */
	/*                              ENUMERABLE LOGIC                              */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the total amount of tokens stored by the contract.
	/// @return The token supply.
	function totalSupply() public view virtual override returns (uint256) {
		// currentIndex is initialized to 1 so it cannot underflow.
		unchecked {
			return currentIndex - 1;
		}
	}

	/// @notice Returns a token ID owned by `owner` at a given `index` of its token list.
	/// @dev Use along with {balanceOf} to enumerate all of `owner`'s tokens.
	/// This read function is O({totalSupply}). If calling from a separate contract, be sure to test gas first.
	/// It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case.
	/// @param owner The address to query.
	/// @param index The index to query.
	/// @return The token ID.
	function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
		require(index < balanceOf(owner), "INVALID_INDEX");

		uint256 minted = currentIndex;
		uint256 ownerIndex;
		address currOwner;

		// Counter overflow is incredibly unrealistic.
		unchecked {
			for (uint256 i = 0; i < minted; i++) {
				address _owner = _ownerships[i].owner;
				if (_owner != address(0)) {
					currOwner = _owner;
				}
				if (currOwner == owner) {
					if (ownerIndex == index) {
						return i;
					}
					ownerIndex++;
				}
			}
		}

		revert("NOT_FOUND");
	}

	/// @notice Returns a token ID at a given `index` of all the tokens stored by the contract.
	/// @dev Use along with {totalSupply} to enumerate all tokens.
	/// @param index The index to query.
	/// @return The token ID.
	function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
		require(_exists(index), "INVALID_INDEX");
		return index;
	}

	/* -------------------------------------------------------------------------- */
	/*                                ERC721 LOGIC                                */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the number of tokens in an account.
	/// @param owner The address to query.
	/// @return The balance.
	function balanceOf(address owner) public view virtual override returns (uint256) {
		require(owner != address(0), "INVALID_OWNER");
		return uint256(_addressData[owner].balance);
	}

	/// @notice Returns the owner of a token ID.
	/// @dev Requirements:
	/// - `id` must exist.
	/// @param id The token ID.
	function ownerOf(uint256 id) public view virtual override returns (address) {
		return _ownershipOf(id).owner;
	}

	/* -------------------------------------------------------------------------- */
	/*                           INTERNAL GENERAL LOGIC                           */
	/* -------------------------------------------------------------------------- */

	/// @dev Returns whether a token ID exists.
	/// Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
	/// Tokens start existing when they are minted.
	/// @param id Token ID to query.
	function _exists(uint256 id) internal view virtual override returns (bool) {
		return id != 0 && id < currentIndex;
	}

	/// @notice Returns all token IDs owned by an address.
	/// This read function is O({totalSupply}). If calling from a separate contract, be sure to test gas first.
	/// It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case.
	/// @param owner Address to query.
	/// @return ids An array of the ID's owned by `owner`.
	function _idsOfOwner(address owner) internal view virtual returns (uint256[] memory ids) {
		uint256 bal = uint256(_addressData[owner].balance);
		if (bal == 0) return ids;

		ids = new uint256[](bal);

		uint256 minted = currentIndex;
		address currOwner;
		uint256 index;

		unchecked {
			for (uint256 i = 1; i < minted; i++) {
				address _owner = _ownerships[i].owner;

				if (_owner != address(0)) {
					currOwner = _owner;
				}

				if (currOwner == owner) {
					ids[index++] = i;
					if (index == bal) return ids;
				}
			}
		}
	}

	function _numberMinted(address owner) public view virtual returns (uint256) {
		require(owner != address(0), "INVALID_OWNER");
		return uint256(_addressData[owner].numberMinted);
	}

	function _ownershipOf(uint256 id) internal view virtual returns (TokenOwnership memory) {
		require(_exists(id), "NONEXISTENT_TOKEN");

		unchecked {
			for (uint256 curr = id; curr >= 0; curr--) {
				TokenOwnership memory ownership = _ownerships[curr];
				if (ownership.owner != address(0)) {
					return ownership;
				}
			}
		}

		revert("NOT_FOUND");
	}

	function _transfer(
		address from,
		address to,
		uint256 id
	) internal virtual override {
		TokenOwnership memory prevOwnership = _ownershipOf(id);

		require(prevOwnership.owner == from, "WRONG_FROM");
		require(to != address(0), "INVALID_RECIPIENT");
		require(msg.sender == from || getApproved(id) == msg.sender || isApprovedForAll(from, msg.sender), "NOT_AUTHORIZED");

		// Clear approvals
		delete _tokenApprovals[id];

		// Underflow of the sender's balance is impossible because we check for
		// ownership above and the recipient's balance can't realistically overflow.
		unchecked {
			_addressData[from].balance -= 1;
			_addressData[to].balance += 1;

			// Set new owner
			_ownerships[id].owner = to;

			uint256 nextId = id + 1;
			// If the ownership slot of id + 1 is not explicitly set, that means the transfer initiator owns it.
			// Set the slot of id + 1 explicitly in storage to maintain correctness for ownerOf(id + 1) calls.
			if (_ownerships[nextId].owner == address(0)) {
				if (_exists(nextId)) {
					_ownerships[nextId].owner = prevOwnership.owner;
				}
			}
		}
		emit Transfer(from, to, id);
	}

	/// @dev Mints `amount` tokens to `to`.
	/// Requirements:
	/// - there must be `amount` tokens remaining unminted in the total collection.
	/// - `to` cannot be the zero address.
	/// Emits `amount` {Transfer} events.
	/// @param to The address to mint to.
	/// @param amount The amount of tokens to mint.
	function _mint(address to, uint256 amount) internal virtual override {
		require(to != address(0), "INVALID_RECIPIENT");
		require(amount != 0, "INVALID_AMOUNT");

		// Counter or mint amount overflow is incredibly unrealistic.
		unchecked {
			uint256 startId = currentIndex;

			_addressData[to].balance += uint128(amount);
			_addressData[to].numberMinted += uint128(amount);

			_ownerships[startId].owner = to;
			_ownerships[startId].timestamp = uint64(block.timestamp);

			for (uint256 i; i < amount; i++) {
				emit Transfer(address(0), to, startId);
				startId++;
			}

			currentIndex = startId;
		}
	}
}
