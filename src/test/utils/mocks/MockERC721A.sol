// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "../../../tokens/ERC721/ERC721A.sol";

// solhint-disable no-empty-blocks

contract MockERC721A is ERC721A, Ownable, ReentrancyGuard {
	constructor(
		string memory _name,
		string memory _symbol,
		string memory _baseURI
	) payable ERC721A(_name, _symbol) {
		baseURI = _baseURI;
	}

	string public baseURI;

	function setBaseURI(string calldata _baseURI) external {
		baseURI = _baseURI;
	}

	function tokenURI(uint256 id) public view override returns (string memory) {
		string memory _baseURI = baseURI;
		return bytes(_baseURI).length == 0 ? "" : string(abi.encodePacked(_baseURI, toString(id)));
	}

	function idsOfOwner(address owner) external view returns (uint256[] memory) {
		return _idsOfOwner(owner);
	}

	function exists(uint256 tokenId) public view returns (bool) {
		return _exists(tokenId);
	}

	function safeMint(address to, uint256 quantity) public payable {
		_safeMint(to, quantity);
	}
}
