// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ERC721A } from "../ERC721A.sol";

/// @author @DaniPopes
/// @notice OpenSea proxy registry interface.
interface IProxyRegistry {
	function proxies(address) external view returns (address);
}

/// @author @DaniPopes
/// @notice ERC721A extension, inspired by @ProjectOpenSea's opensea-creatures (ERC721Tradable).
/// Whitelists all OpenSea proxy addresses and the LooksRare transfer manager address
/// in {isApprovedForAll} and saves up to 50,000 gas for each account by removing the need
/// to {setApprovalForAll} before being able to trade on the marketplaces.
/// @dev Mitigating this issue: https://github.com/chiru-labs/ERC721A/issues/40#issuecomment-1024861728
/// by providing a function ({setMarketplaceApprovalForAll}) to revoke these approvals.
abstract contract ERC721ATradable is ERC721A {
	/* -------------------------------------------------------------------------- */
	/*                              IMMUTABLE STORAGE                             */
	/* -------------------------------------------------------------------------- */

	/// @notice The OpenSea Proxy Registry address.
	address public immutable openSeaProxyRegistry;

	/// @notice The LooksRare Transfer Manager (ERC721) address.
	address public immutable looksRareTransferManager;

	/* -------------------------------------------------------------------------- */
	/*                               MUTABLE STORAGE                              */
	/* -------------------------------------------------------------------------- */

	/// @notice Returns true if the stored marketplace addresses are whitelisted in {isApprovedForAll}.
	/// @dev Enabled by default. Switch off with {setMarketplaceApprovalForAll}.
	bool public marketPlaceApprovalForAll = true;

	/* -------------------------------------------------------------------------- */
	/*                                 CONSTRUCTOR                                */
	/* -------------------------------------------------------------------------- */

	/// @dev Requirements:
	/// - `_openSeaProxyRegistry` must not be the 0 address.
	/// - `_looksRareTransferManager` must not be the 0 address.
	/// OpenSea proxy registry addresses:
	/// ETHEREUM MAINNET: 0xa5409ec958C83C3f309868babACA7c86DCB077c1
	/// ETHEREUM RINKEBY: 0xF57B2c51dED3A29e6891aba85459d600256Cf317
	/// LooksRare Transfer Manager addresses (https://docs.looksrare.org/developers/deployed-contract-addresses):
	/// ETHEREUM MAINNET: 0xf42aa99F011A1fA7CDA90E5E98b277E306BcA83e
	/// ETHEREUM RINKEBY: 0x3f65A762F15D01809cDC6B43d8849fF24949c86a
	/// @param _openSeaProxyRegistry The OpenSea proxy registry address.
	constructor(address _openSeaProxyRegistry, address _looksRareTransferManager) {
		require(_openSeaProxyRegistry != address(0) && _looksRareTransferManager != address(0), "INVALID_ADDRESS");
		openSeaProxyRegistry = _openSeaProxyRegistry;
		looksRareTransferManager = _looksRareTransferManager;
	}

	/* -------------------------------------------------------------------------- */
	/*                            ERC721ATradable LOGIC                           */
	/* -------------------------------------------------------------------------- */

	/// @notice Toggles the marketplace whitelist status.
	/// @dev Must be implemented in inheriting contracts.
	/// Recommended to use in combination with an access control contract (e.g. OpenZeppelin's Ownable).
	function setMarketplaceApprovalForAll(bool approved) public virtual;

	/// @return True if `operator` is a whitelisted marketplace contract or if it was approved by `owner` with {ERC721A.setApprovalForAll}.
	/// @inheritdoc ERC721A
	function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
		if (marketPlaceApprovalForAll && (operator == IProxyRegistry(openSeaProxyRegistry).proxies(owner) || operator == looksRareTransferManager)) return true;
		return super.isApprovedForAll(owner, operator);
	}
}
