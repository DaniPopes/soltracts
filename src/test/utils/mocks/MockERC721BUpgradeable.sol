// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../upgradable/tokens/ERC721/ERC721BUpgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract MockERC721BUpgradeable is ERC721BUpgradeable {
    string public baseURI;

    function initialize() external initializer {
        __ERC721B_init("TestName", "TestSymbol");
    }

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

    function mint(address to, uint256 amount) public payable {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public payable {
        _safeMint(to, amount);
    }
}
