// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../tokens/ERC721/extensions/ERC721ATradable.sol";

contract MockERC721ATradable is ERC721ATradable {
	constructor(
		string memory _name,
		string memory _symbol,
		address _openSeaProxyRegistry,
		address _looksRareTransferManager
	) payable ERC721A(_name, _symbol) ERC721ATradable(_openSeaProxyRegistry, _looksRareTransferManager) {}

	function safeMint(address to, uint256 amount) external {
		_safeMint(to, amount);
	}

	function setMarketplaceApprovalForAll(bool approved) public override {
		marketPlaceApprovalForAll = approved;
	}

	function tokenURI(uint256 id) public view override returns (string memory) {}
}
