// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Initializable } from "../../proxy/utils/Initializable.sol";
import { ERC721TokenReceiverUpgradeable } from "./ERC721TokenReceiverUpgradeable.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Abstract implementation of the [ERC721](https://eips.ethereum.org/EIPS/eip-721) Non-Fungible Token Standard,
/// with logic implementations of only metadata, token approvals and extensive NATSPEC.
/// Used as base for ERC721 contracts that implement transfer and mint logic like ERC721A or ERC721B.
/// @dev The {transferFrom}, {safeTransferFrom} and {_safeMint} functions call their respective internal
/// {_transfer} and {_mint}.
/// Inheriting contracts must implement the internal functions {_exists}, {_transfer} and {_mint}.
abstract contract ERC721Upgradeable is Initializable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when the queried token ID does not exist.
    error NonExistentToken();

    /// @dev Thrown when the caller is not the owner or it is not authorized to manage a token.
    error NotAuthorized();

    /// @dev Thrown when recipient of a "`safe`" function is not a contract or does not return the correct data.
    error UnsafeRecipient();

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
    mapping(uint256 => address) internal _tokenApprovals;

    /// @dev owner => operator => approved
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZER                                */
    /* -------------------------------------------------------------------------- */

    /// @param name_ The collection name.
    /// @param symbol_ The collection symbol.
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /* -------------------------------------------------------------------------- */
    /*                                ERC165 LOGIC                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns true if this contract implements an interface from its ID.
    /// @dev See the corresponding
    /// [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
    /// to learn more about how these IDs are created.
    /// @return The implementation status.
    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
            interfaceId == 0x780e9d63; // ERC165 Interface ID for ERC721Enumerable
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
    /// @param id The token ID.
    /// @return The URI.
    function tokenURI(uint256 id) public view virtual returns (string memory);

    /* -------------------------------------------------------------------------- */
    /*                              ENUMERABLE LOGIC                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the total amount of tokens stored by the contract.
    /// @return The token supply.
    function totalSupply() public view virtual returns (uint256);

    /// @notice Returns a token ID owned by `owner` at a given `index` of its token list.
    /// @dev Use along with {balanceOf} to enumerate all of `owner`'s tokens.
    /// @param owner The address to query.
    /// @param index The index to query.
    /// @return The token ID.
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        returns (uint256);

    /// @notice Returns a token ID at a given `index` of all the tokens stored by the contract.
    /// @dev Use along with {totalSupply} to enumerate all tokens.
    /// @param index The index to query.
    /// @return The token ID.
    function tokenByIndex(uint256 index) public view virtual returns (uint256);

    /* -------------------------------------------------------------------------- */
    /*                                ERC721 LOGIC                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns the account approved for a token ID.
    /// @dev Requirements:
    /// - `id` must exist.
    /// @param id Token ID to query.
    /// @return The account approved for `id` token.
    function getApproved(uint256 id) public view virtual returns (address) {
        if (!_exists(id)) revert NonExistentToken();
        return _tokenApprovals[id];
    }

    /// @notice Returns `true` if the `operator` is allowed to manage all of the assets of `owner`.
    /// @param owner The address of the owner.
    /// @param operator The address of the operator.
    /// @return `true` if `operator` was approved by `owner`.
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _operatorApprovals[owner][operator];
    }

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

        if (!isApprovedForAll(owner, msg.sender) && msg.sender != owner) revert NotAuthorized();

        _tokenApprovals[id] = spender;

        emit Approval(owner, spender, id);
    }

    /// @notice Approve or remove `operator` as an operator for the caller.
    /// @dev Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
    /// Emits an {ApprovalForAll} event.
    /// @param operator The address of the operator to approve.
    /// @param approved The status to set.
    function setApprovalForAll(address operator, bool approved) public virtual {
        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
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
    /// - If `to` refers to a smart contract, it must implement {ERC721TokenReceiverUpgradeable-onERC721Received}, which is called upon a safe transfer.
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

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(msg.sender, from, id, "") !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert UnsafeRecipient();
    }

    /// @notice Safely transfers `id` token from `from` to `to`.
    /// @dev Requirements:
    /// - `to` cannot be the zero address.
    /// - `id` token must exist and be owned by `from`.
    /// - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
    /// - If `to` refers to a smart contract, it must implement {ERC721TokenReceiverUpgradeable-onERC721Received}, which is called upon a safe transfer.
    /// Emits a {Transfer} event.
    /// Additionally passes `data` in the callback.
    /// @param from The address to transfer from.
    /// @param to The address to transfer to.
    /// @param id The token ID to transfer.
    /// @param data The calldata to pass in the {ERC721TokenReceiverUpgradeable-onERC721Received} callback.
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public virtual {
        _transfer(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(msg.sender, from, id, data) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert UnsafeRecipient();
    }

    /// @notice Returns the number of tokens in an account.
    /// @param owner The address to query.
    /// @return The balance.
    function balanceOf(address owner) public view virtual returns (uint256);

    /// @notice Returns the owner of a token ID.
    /// @dev Requirements:
    /// - `id` must exist.
    /// @param id The token ID.
    function ownerOf(uint256 id) public view virtual returns (address);

    /* -------------------------------------------------------------------------- */
    /*                               INTERNAL LOGIC                               */
    /* -------------------------------------------------------------------------- */

    /// @dev Returns whether a token ID exists.
    /// Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
    /// Tokens start existing when they are minted.
    /// @param id The token ID to query.
    function _exists(uint256 id) internal view virtual returns (bool);

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
    ) internal virtual;

    /// @dev Mints `id` token and transfers it to `to`.
    /// Requirements:
    /// - `id` token must not exist (have been minted) already.
    /// - `to` cannot be the zero address.
    /// Emits a {Transfer} event.
    /// @param to The address to mint to.
    /// @param id The token ID to mint.
    function _mint(address to, uint256 id) internal virtual;

    /// @dev Safely mints `id` token and transfers it to `to`.
    /// Requirements:
    /// - `id` token must not exist (have been minted) already.
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiverUpgradeable.onERC721Received}
    /// that returns {ERC721TokenReceiverUpgradeable.onERC721Received.selector}.
    /// Emits a {Transfer} event.
    /// @param to The address to mint to.
    /// @param id The token ID to mint.
    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(address(0), to, id, "") !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert UnsafeRecipient();
    }

    /// @dev Safely mints `id` token and transfers it to `to`.
    /// Requirements:
    /// - `id` token must not exist (have been minted) already.
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiverUpgradeable.onERC721Received}
    /// that returns {ERC721TokenReceiverUpgradeable.onERC721Received.selector}.
    /// Emits a {Transfer} event.
    /// Additionally passes `data` in the callback.
    /// @param to The address to mint to.
    /// @param id The token ID to mint.
    /// @param data The calldata to pass in the {ERC721TokenReceiverUpgradeable.onERC721Received} callback.
    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0 &&
            ERC721TokenReceiverUpgradeable(to).onERC721Received(address(0), to, id, data) !=
            ERC721TokenReceiverUpgradeable.onERC721Received.selector
        ) revert UnsafeRecipient();
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
