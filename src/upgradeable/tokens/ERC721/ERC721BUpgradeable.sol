// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import { ERC721Upgradeable, ERC721TokenReceiverUpgradeable } from "./ERC721Upgradeable.sol";

/// @notice Updated, minimalist and gas efficient version of OpenZeppelins ERC721 contract.
/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @author Modified from beskay (https://github.com/beskay/ERC721B).
/// @dev Includes better NATSPEC, shorter error strings, further gas optimizations.
/// Includes the Metadata and Enumerable extension.
/// Assumes serials are sequentially minted starting at 0 (e.g. 0, 1, 2, 3..).
/// Does not support burning tokens to address(0).
abstract contract ERC721BUpgradeable is ERC721Upgradeable {
    /* -------------------------------------------------------------------------- */
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when queried index is out of bounds.
    error InvalidIndex();

    /// @dev Thrown when queried owner is address(0).
    error InvalidOwner();

    /// @dev Thrown when transfer or mint recipient is address(0).
    error InvalidRecipient();

    /// @dev Thrown when mint amount is 0.
    error InvalidAmount();

    /// @dev Thrown when `from` transfer parameter is address(0).
    error WrongFrom();

    /* -------------------------------------------------------------------------- */
    /*                               ERC721B STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Array which maps token ID to address (index is id).
    address[] internal _owners;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZER                                */
    /* -------------------------------------------------------------------------- */

    function __ERC721B_init(string memory name_, string memory symbol_) internal {
        __ERC721_init(name_, symbol_);
        // init to 1
        _owners.push();
    }

    /* -------------------------------------------------------------------------- */
    /*                              ENUMERABLE LOGIC                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc ERC721Upgradeable
    function totalSupply() public view override returns (uint256) {
        // Owner index is initialized to 1 so it cannot underflow.
        unchecked {
            return _owners.length - 1;
        }
    }

    /// @dev Use along with {balanceOf} to enumerate all of `owner`"s tokens.
    /// Dont call this function on chain from another smart contract, since it can become quite expensive
    /// @inheritdoc ERC721Upgradeable
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (index >= balanceOf(owner)) revert InvalidIndex();

        uint256 count;
        uint256 length = _owners.length;
        for (uint256 i = 1; i < length; i++) {
            if (owner == ownerOf(i)) {
                if (count == index) return i;
                else count++;
            }
        }

        revert("NOT_FOUND");
    }

    /// @inheritdoc ERC721Upgradeable
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        if (!_exists(index)) revert InvalidIndex();
        return index;
    }

    /* -------------------------------------------------------------------------- */
    /*                                ERC721 LOGIC                                */
    /* -------------------------------------------------------------------------- */

    /// @dev Iterates through _owners array.
    /// It is not recommended to call this function from another smart contract
    /// as it can become quite expensive -- call this function off chain instead.
    /// @inheritdoc ERC721Upgradeable
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) revert InvalidOwner();

        uint256 count;
        uint256 length = _owners.length;
        for (uint256 i = 1; i < length; i++) {
            if (owner == ownerOf(i)) {
                unchecked {
                    count++;
                }
            }
        }
        return count;
    }

    /// @inheritdoc ERC721Upgradeable
    function ownerOf(uint256 id) public view virtual override returns (address) {
        if (!_exists(id)) revert NonExistentToken();

        for (uint256 i = id; ; i++) {
            address _owner = _owners[i];
            if (_owner != address(0)) {
                return _owner;
            }
        }

        revert("NOT_FOUND");
    }

    /* -------------------------------------------------------------------------- */
    /*                               INTERNAL LOGIC                               */
    /* -------------------------------------------------------------------------- */

    /// @dev Mints `amount` of tokens and transfers them to `to`.
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiver.onERC721Received}
    /// that returns {ERC721TokenReceiver.onERC721Received.selector}.
    /// @param amount Amount of tokens to mint.
    /// @inheritdoc ERC721Upgradeable
    function _mint(address to, uint256 amount) internal virtual override {
        if (to == address(0)) revert InvalidRecipient();
        if (amount == 0) revert InvalidAmount();

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

    /// @dev Mints `amount` of tokens and transfers them safely to `to`.
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiver.onERC721Received}
    /// that returns {ERC721TokenReceiver.onERC721Received.selector}.
    /// Emits `amount` {Transfer} events.
    /// @param amount Amount of tokens to mint.
    /// @inheritdoc ERC721Upgradeable
    function _safeMint(address to, uint256 amount) internal virtual override {
        _mint(to, amount);

        unchecked {
            if (to.code.length != 0) {
                uint256 idx = _owners.length;
                for (uint256 i = idx - amount; i < idx; i++)
                    if (
                        ERC721TokenReceiverUpgradeable(to).onERC721Received(
                            msg.sender,
                            address(0),
                            i,
                            ""
                        ) != ERC721TokenReceiverUpgradeable.onERC721Received.selector
                    ) revert UnsafeRecipient();
            }
        }
    }

    /// @dev Mints `amount` of tokens and transfers them safely to `to`.
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiver.onERC721Received}
    /// that returns {ERC721TokenReceiver.onERC721Received.selector}.
    /// Emits `amount` {Transfer} events.
    /// Additionally passes `data` in the callback.
    /// @param amount Amount of tokens to mint.
    /// @inheritdoc ERC721Upgradeable
    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal virtual override {
        _mint(to, amount);

        unchecked {
            if (to.code.length != 0) {
                uint256 idx = _owners.length;
                for (uint256 i = idx - amount; i < idx; i++)
                    if (
                        ERC721TokenReceiverUpgradeable(to).onERC721Received(
                            msg.sender,
                            address(0),
                            i,
                            data
                        ) != ERC721TokenReceiverUpgradeable.onERC721Received.selector
                    ) revert UnsafeRecipient();
            }
        }
    }

    /// @inheritdoc ERC721Upgradeable
    function _exists(uint256 id) internal view virtual override returns (bool) {
        return id != 0 && id < _owners.length;
    }

    /// @inheritdoc ERC721Upgradeable
    function _transfer(
        address from,
        address to,
        uint256 id
    ) internal virtual override {
        if (from != ownerOf(id)) revert WrongFrom();
        if (to == address(0)) revert InvalidRecipient();
        if (
            !isApprovedForAll(from, msg.sender) &&
            msg.sender != from &&
            msg.sender != getApproved(id)
        ) revert NotAuthorized();

        // Clear approvals
        delete _tokenApprovals[id];

        // Set new owner
        _owners[id] = to;

        // if token ID below transferred one isn't set, set it to previous owner
        unchecked {
            uint256 prevId = id - 1;
            if (_owners[prevId] == address(0)) {
                _owners[prevId] = from;
            }
        }

        emit Transfer(from, to, id);
    }
}
