// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// solhint-disable

contract MockTransferManagerERC721 {
	event GM(address indexed gmer);

	function transferFrom(
		address token,
		address from,
		address to,
		uint256 id
	) external {
		emit GM(from);
	}
}
