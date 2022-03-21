// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "forge-std/stdlib.sol";
import "solmate/test/utils/DSTestPlus.sol";
import "forge-std/console.sol";

abstract contract BaseTest is DSTestPlus, stdCheats {
    Hevm internal constant vm = Hevm(HEVM_ADDRESS);

    address internal constant alice =
        address(uint160(uint256(keccak256(abi.encodePacked("alice")))));
    address internal constant bob = address(uint160(uint256(keccak256(abi.encodePacked("bob")))));
    address internal constant dead = 0x000000000000000000000000000000000000dEaD;

    constructor() payable {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(vm), "VM");
        vm.label(console.CONSOLE_ADDRESS, "Console");
        vm.label(dead, "Dead");
        vm.label(address(0), "address(0)");
    }

    string private label = "1";
    uint256 private gasBefore = 1;
    uint256 private gasCounter = 1;

    function startMeasuringGas(string memory _label) internal virtual override {
        label = _label;
        uint256 _gasBefore = gasleft();
        gasBefore = _gasBefore;
    }

    function stopMeasuringGas() internal virtual override {
        uint256 gasAfter = gasleft();

        // remove 100 for warm SLOAD, 500
        uint256 gasDelta = gasBefore - gasAfter - 100;
        if (gasDelta > 500) gasDelta -= 500;
        if (gasCounter++ == 1 && gasDelta > 1600) gasDelta -= 1600;
        console.log(string(abi.encodePacked(label, " Gas")), gasDelta);
    }

    function getRandomAddress(uint256 salt) internal virtual returns (address) {
        return address(uint160(getRandom256(salt)));
    }

    function getRandom256(uint256 salt) internal virtual returns (uint256) {
        return uint256(keccak256(abi.encodePacked(salt)));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external view virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
