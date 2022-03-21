// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ERC721, ERC721TokenReceiver } from "./ERC721.sol";

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
    /*                                   ERRORS                                   */
    /* -------------------------------------------------------------------------- */

    /// @dev Thrown when queried index is out of bounds.
    error invalidIndex();

    /// @dev Thrown when queried owner is address(0).
    error invalidOwner();

    /// @dev Thrown when transfer or mint recipient is address(0).
    error invalidRecipient();

    /// @dev Thrown when mint amount is 0.
    error invalidAmount();

    /// @dev Thrown when `from` transfer parameter is address(0).
    error wrongFrom();

    /// @dev Thrown when couldn't find queried token. Should never happen.
    error notFound();

    /* -------------------------------------------------------------------------- */
    /*                               ERC721A STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Values are packed in a 256 bit word.
    struct AddressData {
        uint128 balance;
        uint128 numberMinted;
    }

    /// @dev Values are packed in a 256 bit word.
    struct TokenOwnership {
        address owner;
        uint64 timestamp;
    }

    /// @dev A counter that increments for each minted token.
    /// Initialized to 1 to make all token ids (1 : `maxSupply`) instead of (0 : (`maxSupply` - 1)).
    /// Although `maxSupply` is not implemented, it is recommended in all contracts using this implementation.
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

    /// @inheritdoc ERC721
    function totalSupply() public view virtual override returns (uint256) {
        // currentIndex is initialized to 1 so it cannot underflow.
        unchecked {
            return currentIndex - 1;
        }
    }

    /// @dev Use along with {balanceOf} to enumerate all of `owner`'s tokens.
    /// WARNING: This function is extremely gas-inefficient as it is O({totalSupply}).
    /// @inheritdoc ERC721
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (index >= balanceOf(owner)) revert invalidIndex();

        uint256 minted = currentIndex;
        uint256 ownerIndex;
        address currOwner;

        // Counter overflow is incredibly unrealistic.
        unchecked {
            for (uint256 i = 0; i < minted; i++) {
                address _owner = _ownerships[i].owner;
                if (_owner != address(0)) currOwner = _owner;

                if (currOwner == owner) {
                    if (ownerIndex == index) return i;

                    ownerIndex++;
                }
            }
        }

        revert("NOT_FOUND");
    }

    /// @inheritdoc ERC721
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        if (!_exists(index)) revert invalidIndex();
        return index;
    }

    /* -------------------------------------------------------------------------- */
    /*                                ERC721 LOGIC                                */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc ERC721
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) revert invalidOwner();
        return uint256(_addressData[owner].balance);
    }

    /// @inheritdoc ERC721
    function ownerOf(uint256 id) public view virtual override returns (address) {
        return _ownershipOf(id).owner;
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
    /// @inheritdoc ERC721
    function _mint(address to, uint256 amount) internal virtual override {
        if (to == address(0)) revert invalidRecipient();
        if (amount == 0) revert invalidAmount();

        // Counter or mint amount overflow is incredibly unrealistic.
        unchecked {
            uint256 startId = currentIndex;

            _addressData[to].balance += uint128(amount);
            _addressData[to].numberMinted += uint128(amount);

            _ownerships[startId].owner = to;
            _ownerships[startId].timestamp = uint64(block.timestamp);

            for (uint256 i; i < amount; i++) emit Transfer(address(0), to, startId++);

            currentIndex = startId;
        }
    }

    /// @dev Mints `amount` of tokens and transfers them safely to `to`.
    /// Requirements:
    /// - `to` cannot be the zero address.
    /// - If `to` is a contract it must implement {ERC721TokenReceiver.onERC721Received}
    /// that returns {ERC721TokenReceiver.onERC721Received.selector}.
    /// Emits `amount` {Transfer} events.
    /// @param amount Amount of tokens to mint.
    /// @inheritdoc ERC721
    function _safeMint(address to, uint256 amount) internal virtual override {
        _mint(to, amount);

        unchecked {
            if (to.code.length != 0) {
                uint256 idx = currentIndex;
                for (uint256 i = idx - amount; i < idx; i++)
                    if (
                        ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), i, "") !=
                        ERC721TokenReceiver.onERC721Received.selector
                    ) revert unsafeRecipient();
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
    /// @inheritdoc ERC721
    function _safeMint(
        address to,
        uint256 amount,
        bytes calldata data
    ) internal virtual override {
        _mint(to, amount);

        unchecked {
            if (to.code.length != 0) {
                uint256 idx = currentIndex;
                for (uint256 i = idx - amount; i < idx; i++)
                    if (
                        ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), i, data) !=
                        ERC721TokenReceiver.onERC721Received.selector
                    ) revert unsafeRecipient();
            }
        }
    }

    /// @inheritdoc ERC721
    function _exists(uint256 id) internal view virtual override returns (bool) {
        return id != 0 && id < currentIndex;
    }

    /// @inheritdoc ERC721
    function _transfer(
        address from,
        address to,
        uint256 id
    ) internal virtual override {
        // _ownershipOf also checks for existence
        TokenOwnership memory prevOwnership = _ownershipOf(id);
        address owner = prevOwnership.owner;

        if (from != owner) revert wrongFrom();
        if (to == address(0)) revert invalidRecipient();
        if (
            !isApprovedForAll(owner, msg.sender) &&
            msg.sender != owner &&
            msg.sender != getApproved(id)
        ) revert notAuthorized();

        // Clear approvals
        delete _tokenApprovals[id];

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _addressData[from].balance--;
            _addressData[to].balance++;

            // Set new owner
            _ownerships[id].owner = to;

            uint256 nextId = id + 1;
            // If the ownership slot of id + 1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of id + 1 explicitly in storage to maintain correctness for ownerOf(id + 1) calls.
            if (_ownerships[nextId].owner == address(0) && _exists(nextId))
                _ownerships[nextId].owner = prevOwnership.owner;
        }

        emit Transfer(from, to, id);
    }

    /// @dev Returns the total number of tokens minted by and address.
    /// @param owner Address to query.
    /// @return Number of tokens minted by `owner`.
    function _numberMinted(address owner) public view virtual returns (uint256) {
        if (owner == address(0)) revert invalidOwner();
        return uint256(_addressData[owner].numberMinted);
    }

    /// @dev Returns the ownership values for a token ID.
    /// @param id Token ID to query.
    /// @return {TokenOwnership} of `id`.
    function _ownershipOf(uint256 id) internal view virtual returns (TokenOwnership memory) {
        if (!_exists(id)) revert nonExistentToken();

        unchecked {
            for (uint256 curr = id; curr > 0; curr--) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (ownership.owner != address(0)) {
                    return ownership;
                }
            }
        }

        revert notFound();
    }

    /// @dev Returns all token IDs owned by an address.
    /// WARNING: This function is extremely gas-inefficient as it is O({totalSupply}).
    /// @param owner Address to query.
    /// @return ids An array of the ID's owned by `owner`.
    function _idsOfOwner(address owner) internal view virtual returns (uint256[] memory ids) {
        uint256 bal = balanceOf(owner);
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
}
