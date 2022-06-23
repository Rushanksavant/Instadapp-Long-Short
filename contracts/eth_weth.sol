// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./starters.sol";
import "hardhat/console.sol";

contract getWETH is starters {
    constructor() {
        myDSA = instaIndex.build(address(this), 2, address(0));
    }

    function WETHget() external payable {
        uint256 amt = msg.value;

        string[] memory _targets = new string[](1);
        bytes[] memory _data = new bytes[](1);

        bytes4 deposit = bytes4(keccak256("deposit(uint256,uint256,uint256)"));

        (_targets[0], _data[0]) = (
            "WETH-A",
            abi.encodeWithSelector(deposit, amt, 0, 0)
        );

        IDSA(myDSA).cast{value: amt}(_targets, _data, address(0));
    }
}
