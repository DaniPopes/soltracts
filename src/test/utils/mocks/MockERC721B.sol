// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@rari-capital/solmate/src/utils/ReentrancyGuard.sol";
import "../../../tokens/ERC721/ERC721B.sol";

contract MockERC721B is ERC721B, Ownable, ReentrancyGuard {
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) payable ERC721B(_name, _symbol) {
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

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function safeMint(address to, uint256 quantity) public payable {
        _safeMint(to, quantity);
    }
}
