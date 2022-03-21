// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Tradable.sol";

contract MockERC721Tradable is ERC721A, ERC721Tradable {
	constructor(
		string memory _name,
		string memory _symbol,
		address _openSeaProxyRegistry,
		address _looksRareTransferManager
	) payable ERC721A(_name, _symbol) ERC721Tradable(_openSeaProxyRegistry, _looksRareTransferManager) {}

	function safeMint(address to, uint256 amount) external {
		_safeMint(to, amount);
	}

	function setMarketplaceApprovalForAll(bool approved) public {
		_setMarketplaceApprovalForAll(approved);
	}

	function tokenURI(uint256 id) public view override returns (string memory) {}

	function isApprovedForAll(address a, address b) public view override(ERC721, ERC721Tradable) returns (bool c) {
		return super.isApprovedForAll(a, b);
	}
}
