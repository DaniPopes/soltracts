// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { ERC721Upgradeable } from "../ERC721Upgradeable.sol";

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice OpenSea proxy registry interface.
interface IProxyRegistry {
    function proxies(address) external view returns (address);
}

/// @author DaniPopes (https://github.com/danipopes/soltracts/)
/// @notice Tradable extension for ERC721, inspired by @ProjectOpenSea's opensea-creatures (ERC721Tradable).
/// Whitelists all OpenSea proxy addresses and the LooksRare transfer manager address
/// in {isApprovedForAll} and saves up to 50,000 gas for each account by removing the need
/// to {setApprovalForAll} before being able to trade on said marketplaces.
/// @dev Mitigated [this issue](https://github.com/chiru-labs/ERC721A/issues/40#issuecomment-1024861728)
/// by providing a function ({_setMarketplaceApprovalForAll}) to revoke the marketplace approvals.
abstract contract ERC721TradableUpgradeable is ERC721Upgradeable {
    /* -------------------------------------------------------------------------- */
    /*                              IMMUTABLE STORAGE                             */
    /* -------------------------------------------------------------------------- */

    /// @notice The OpenSea Proxy Registry address.
    address public openSeaProxyRegistry;

    /// @notice The LooksRare Transfer Manager (ERC721) address.
    address public looksRareTransferManager;

    /* -------------------------------------------------------------------------- */
    /*                               MUTABLE STORAGE                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Returns true if the stored marketplace addresses are whitelisted in {isApprovedForAll}.
    /// @dev Enabled by default. Change with {_setMarketplaceApprovalForAll}.
    bool public marketplaceApprovalForAll;

    /* -------------------------------------------------------------------------- */
    /*                                 INITIALIZER                                */
    /* -------------------------------------------------------------------------- */

    /// @dev Requirements:
    /// - `_openSeaProxyRegistry` must not be the 0 address.
    /// - `_looksRareTransferManager` must not be the 0 address.
    /// OpenSea proxy registry addresses:
    /// - ETHEREUM MAINNET: 0xa5409ec958C83C3f309868babACA7c86DCB077c1
    /// - ETHEREUM RINKEBY: 0xF57B2c51dED3A29e6891aba85459d600256Cf317
    /// LooksRare Transfer Manager addresses (https://docs.looksrare.org/developers/deployed-contract-addresses):
    /// - ETHEREUM MAINNET: 0xf42aa99F011A1fA7CDA90E5E98b277E306BcA83e
    /// - ETHEREUM RINKEBY: 0x3f65A762F15D01809cDC6B43d8849fF24949c86a
    /// @param _openSeaProxyRegistry The OpenSea proxy registry address.
    function __ERC721Tradable_init(
        string memory name_,
        string memory symbol_,
        address _openSeaProxyRegistry,
        address _looksRareTransferManager
    ) internal onlyInitializing {
        __ERC721_init(name_, symbol_);
        openSeaProxyRegistry = _openSeaProxyRegistry;
        looksRareTransferManager = _looksRareTransferManager;
        marketplaceApprovalForAll = true;
    }

    /* -------------------------------------------------------------------------- */
    /*                            ERC721Tradable LOGIC                            */
    /* -------------------------------------------------------------------------- */

    /// @return `true` if `operator` is a whitelisted marketplace contract or if it was approved by `owner` with {ERC721-setApprovalForAll}.
    /// @inheritdoc ERC721Upgradeable
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        if (
            marketplaceApprovalForAll &&
            (operator == IProxyRegistry(openSeaProxyRegistry).proxies(owner) ||
                operator == looksRareTransferManager)
        ) return true;
        return super.isApprovedForAll(owner, operator);
    }

    /// @dev Enables or disables the marketplace whitelist.
    function _setMarketplaceApprovalForAll(bool approved) internal virtual {
        marketplaceApprovalForAll = approved;
    }
}
