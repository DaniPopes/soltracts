// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721) Non-Fungible Token Standard,
/// including the Metadata and Enumerable extension. Built to optimize for lowest gas possible during mints.
/// @dev Mix of ERC721 implementations by openzeppelin/openzeppelin-contracts, rari-capital/solmate
/// and chiru-labs/ERC721A with many additional optimizations.
/// Assumes serials are sequentially minted starting at 1 (e.g. 1, 2, 3, 4...).
/// Does not support burning tokens to address(0).
/// Missing function implementations:
/// - {tokenURI}.
abstract contract ERC721A {
	/* -------------------------------------------------------------------------- */
	/*                                   EVENTS                                   */
	/* -------------------------------------------------------------------------- */

	/// @dev Emitted when `id` token is transferred from `from` to `to`.
	event Transfer(address indexed from, address indexed to, uint256 indexed id);

	/// @dev Emitted when `owner` enables `approved` to manage the `id` token.
	event Approval(address indexed owner, address indexed spender, uint256 indexed id);

	/// @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
	event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

	/* -------------------------------------------------------------------------- */
	/*                              METADATA STORAGE                              */
	/* -------------------------------------------------------------------------- */

	/// @dev The collection name.
	string internal _name;

	/// @dev The collection symbol.
	string internal _symbol;

	/* -------------------------------------------------------------------------- */
	/*                               ERC721 STORAGE                               */
	/* -------------------------------------------------------------------------- */

	/// @dev ID => spender
	mapping(uint256 => address) internal _getApproved;

	/// @dev owner => operator => approved
	mapping(address => mapping(address => bool)) internal _isApprovedForAll;

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
	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	/* -------------------------------------------------------------------------- */
	/*                               METADATA LOGIC                               */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the collection name.
	/// @return The collection name.
	function name() public view virtual returns (string memory) {
		return _name;
	}

	/// @notice Returns the collection symbol.
	/// @return The collection symbol.
	function symbol() public view virtual returns (string memory) {
		return _symbol;
	}

	/// @notice Returns the Uniform Resource Identifier (URI) for `id` token.
	/// @dev Not implemented in {ERC721A}.
	/// @param id The token ID.
	/// @return The URI.
	function tokenURI(uint256 id) public view virtual returns (string memory);

	/* -------------------------------------------------------------------------- */
	/*                              ENUMERABLE LOGIC                              */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns the total amount of tokens stored by the contract.
	/// @return The token supply.
	function totalSupply() public view virtual returns (uint256) {
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
	function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256) {
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
	function tokenByIndex(uint256 index) public view virtual returns (uint256) {
		require(_exists(index), "NONEXISTENT_TOKEN");
		return index;
	}

	/* -------------------------------------------------------------------------- */
	/*                                ERC721 LOGIC                                */
	/* -------------------------------------------------------------------------- */

	/// @notice Gives permission to `to` to transfer `id` token to another account.
	/// @dev The approval is cleared when the token is transferred.
	/// Only a single account can be approved at a time, so approving the zero address clears previous approvals.
	/// Requirements:
	/// - The caller must own the token or be an approved operator.
	/// - `id` must exist.
	/// Emits an {Approval} event.
	/// @param spender The address of the spender to approve to.
	/// @param id The token ID to approve.
	function approve(address spender, uint256 id) public virtual {
		address owner = ownerOf(id);

		require(isApprovedForAll(owner, msg.sender) || msg.sender == owner, "NOT_AUTHORIZED");

		_getApproved[id] = spender;

		emit Approval(owner, spender, id);
	}

	/// @notice Approve or remove `operator` as an operator for the caller.
	/// @dev Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
	/// Emits an {ApprovalForAll} event.
	/// @param operator The address of the operator to approve.
	/// @param approved The status to set.
	function setApprovalForAll(address operator, bool approved) public virtual {
		_isApprovedForAll[msg.sender][operator] = approved;

		emit ApprovalForAll(msg.sender, operator, approved);
	}

	/// @notice Returns the account approved for a token ID.
	/// @dev Requirements:
	/// - `id` must exist.
	/// @param id Token ID to query.
	/// @return The account approved for `id` token.
	function getApproved(uint256 id) public virtual returns (address) {
		require(_exists(id), "NONEXISTENT_TOKEN");
		return _getApproved[id];
	}

	/// @notice Returns if the `operator` is allowed to manage all of the assets of `owner`.
	/// @param owner The address of the owner.
	/// @param operator The address of the operator.
	/// @return True if `operator` was approved by `owner`.
	function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
		return _isApprovedForAll[owner][operator];
	}

	/// @notice Transfers `id` token from `from` to `to`.
	/// WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
	/// @dev Requirements:
	/// - `to` cannot be the zero address.
	/// - `id` token must be owned by `from`.
	/// - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
	/// Emits a {Transfer} event.
	/// @param from The address to transfer from.
	/// @param to The address to transfer to.
	/// @param id The token ID to transfer.
	function transferFrom(
		address from,
		address to,
		uint256 id
	) public virtual {
		_transfer(from, to, id);
	}

	/// @notice Safely transfers `id` token from `from` to `to`.
	/// @dev Requirements:
	/// - `to` cannot be the zero address.
	/// - `id` token must exist and be owned by `from`.
	/// - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
	/// - If `to` refers to a smart contract, it must implement {ERC721TokenReceiver-onERC721Received}, which is called upon a safe transfer.
	/// Emits a {Transfer} event.
	/// @param from The address to transfer from.
	/// @param to The address to transfer to.
	/// @param id The token ID to transfer.
	function safeTransferFrom(
		address from,
		address to,
		uint256 id
	) public virtual {
		_transfer(from, to, id);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	/// @notice Safely transfers `id` token from `from` to `to`.
	/// @dev Requirements:
	/// - `to` cannot be the zero address.
	/// - `id` token must exist and be owned by `from`.
	/// - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
	/// - If `to` refers to a smart contract, it must implement {ERC721TokenReceiver-onERC721Received}, which is called upon a safe transfer.
	/// Emits a {Transfer} event.
	/// Additionally passes `data` in the callback.
	/// @param from The address to transfer from.
	/// @param to The address to transfer to.
	/// @param id The token ID to transfer.
	/// @param data The calldata to pass in the {ERC721TokenReceiver-onERC721Received} callback.
	function safeTransferFrom(
		address from,
		address to,
		uint256 id,
		bytes memory data
	) public virtual {
		_transfer(from, to, id);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	/// @notice Returns the number of tokens in an account.
	/// @param owner The address to query.
	/// @return The balance.
	function balanceOf(address owner) public view virtual returns (uint256) {
		require(owner != address(0), "INVALID_OWNER");
		return uint256(_addressData[owner].balance);
	}

	/// @notice Returns the owner of a token ID.
	/// @dev Requirements:
	/// - `id` must exist.
	/// @param id The token ID.
	function ownerOf(uint256 id) public view virtual returns (address) {
		return _ownershipOf(id).owner;
	}

	/* -------------------------------------------------------------------------- */
	/*                                ERC165 LOGIC                                */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns true if this contract implements an interface from its ID.
	/// @dev See the corresponding
	/// [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
	/// to learn more about how these IDs are created.
	function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
		return
			interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
			interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
			interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
			interfaceId == 0x780e9d63; // ERC165 Interface ID for ERC721Enumerable
	}

	/* -------------------------------------------------------------------------- */
	/*                           INTERNAL GENERAL LOGIC                           */
	/* -------------------------------------------------------------------------- */

	/// @dev Returns whether a token ID exists.
	/// Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
	/// Tokens start existing when they are minted.
	/// @param id Token ID to query.
	function _exists(uint256 id) internal view virtual returns (bool) {
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

	/// @dev Returns the total number of tokens minted by and address.
	/// @param owner Address to query.
	/// @return Number of tokens minted by `owner`.
	function _numberMinted(address owner) public view virtual returns (uint256) {
		require(owner != address(0), "INVALID_OWNER");
		return uint256(_addressData[owner].numberMinted);
	}

	/// @dev Returns the ownership values for a token ID.
	/// @param id Token ID to query.
	/// @return {TokenOwnership} of `id`.
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

	/* -------------------------------------------------------------------------- */
	/*                        INTERNAL TRANSFER/MINT LOGIC                        */
	/* -------------------------------------------------------------------------- */

	/// @dev Transfers `id` from `from` to `to`.
	/// Requirements:
	/// - `to` cannot be the zero address.
	/// - `id` token must be owned by `from`.
	/// Emits a {Transfer} event.
	/// @param from The address to transfer from.
	/// @param to The address to transfer to.
	/// @param id The token ID to transfer.
	function _transfer(
		address from,
		address to,
		uint256 id
	) internal virtual {
		TokenOwnership memory prevOwnership = _ownershipOf(id);

		require((msg.sender == prevOwnership.owner || getApproved(id) == msg.sender || isApprovedForAll(prevOwnership.owner, msg.sender)), "NOT_AUTHORIZED");
		require(prevOwnership.owner == from, "WRONG_FROM");
		require(to != address(0), "INVALID_RECIPIENT");

		// Clear approvals
		delete _getApproved[id];

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
	function _mint(address to, uint256 amount) internal virtual {
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

	/// @dev Safely mints `amount` of tokens and transfers them to `to`.
	/// If `to` is a contract it must implement {ERC721TokenReceiver.onERC721Received}
	/// that returns {ERC721TokenReceiver.onERC721Received.selector}.
	/// @param to The address to mint to.
	/// @param amount The amount of tokens to mint.
	function _safeMint(address to, uint256 amount) internal virtual {
		_mint(to, amount);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(address(0), to, currentIndex - amount, "") == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	/// @dev Safely mints `amount` of tokens and transfers them to `to`.
	/// Requirements:
	/// - `id` must not exist.
	/// - If `to` refers to a smart contract, it must implement {ERC721TokenReceiver.onERC721Received}, which is called upon a safe transfer.
	/// Additionally passes `data` in the callback.
	/// @param to The address to mint to.
	/// @param amount The amount of tokens to mint.
	/// @param data The calldata to pass in the {ERC721TokenReceiver.onERC721Received} callback.
	function _safeMint(
		address to,
		uint256 amount,
		bytes memory data
	) internal virtual {
		_mint(to, amount);

		require(to.code.length == 0 || ERC721TokenReceiver(to).onERC721Received(address(0), to, currentIndex - amount, data) == ERC721TokenReceiver.onERC721Received.selector, "UNSAFE_RECIPIENT");
	}

	/* -------------------------------------------------------------------------- */
	/*                                    UTILS                                   */
	/* -------------------------------------------------------------------------- */

	/// @notice Converts a `uint256` to its ASCII `string` decimal representation.
	/// @dev https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol
	function toString(uint256 value) internal pure virtual returns (string memory) {
		// Inspired by OraclizeAPI's implementation - MIT licence
		// https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

		if (value == 0) {
			return "0";
		}
		uint256 temp = value;
		uint256 digits;
		while (temp != 0) {
			digits++;
			temp /= 10;
		}
		bytes memory buffer = new bytes(digits);
		while (value != 0) {
			digits -= 1;
			buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
			value /= 10;
		}
		return string(buffer);
	}
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol)
interface ERC721TokenReceiver {
	function onERC721Received(
		address operator,
		address from,
		uint256 id,
		bytes calldata data
	) external returns (bytes4);
}
