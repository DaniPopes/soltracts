// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../../tokens/ERC721/ERC721A.sol";
import "../../../tokens/ERC721/extensions/ERC721Batch.sol";

contract MockERC721Batch is ERC721A, ERC721Batch {
	constructor(string memory _name, string memory _symbol) payable ERC721A(_name, _symbol) {}

	function safeMint(address to, uint256 amount) external {
		_safeMint(to, amount);
	}

	function tokenURI(uint256 id) public view override returns (string memory) {}
}
