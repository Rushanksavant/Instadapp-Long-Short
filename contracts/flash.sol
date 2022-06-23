// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./starters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract flash is starters {
    constructor() {
        myDSA = instaIndex.build(address(this), 2, address(0));
    }

    function takePosition() external payable {
        console.log(msg.value);
        uint256 amt = msg.value;
        uint256 borrowAmount = amt * 2;
        uint256 repayAmount = ((borrowAmount * 10005) / 10000);

        string[] memory _targets = new string[](4);
        bytes[] memory _data = new bytes[](4);

        bytes4 flashBorrow = bytes4(
            keccak256("flashBorrowAndCast(address,uint256,uint256,bytes,bytes)")
        );
        bytes4 deposit = bytes4(keccak256("deposit(uint256,uint256,uint256)"));
        bytes4 basicDeposit = bytes4(
            keccak256("deposit(address,uint256,uint256,uint256)")
        );
        bytes4 compoundDeposit = bytes4(
            keccak256("deposit(string,uint256,uint256,uint256)")
        );
        bytes4 flashPayback = bytes4(
            keccak256("flashPayback(address,uint256,uint256,uint256)")
        );

        (_targets[0], _data[0]) = (
            "WETH-A",
            abi.encodeWithSelector(deposit, amt, 0, 0)
        );

        (_targets[1], _data[1]) = (
            "BASIC-A",
            abi.encodeWithSelector(
                basicDeposit,
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                amt / 4,
                0,
                0
            )
        );
        (_targets[2], _data[2]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(compoundDeposit, "WETH-A", amt / 4, 0, 0)
        );

        (_targets[3], _data[3]) = (
            "INSTAPOOL-C",
            abi.encodeWithSelector(
                flashPayback,
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                repayAmount,
                0,
                0
            )
        );

        // flashBorrow spell
        string[] memory spells = new string[](1);
        bytes[] memory datas = new bytes[](1);

        (spells[0], datas[0]) = (
            "INSTAPOOL-C",
            abi.encodeWithSelector(
                flashBorrow,
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // token
                borrowAmount, // amount of wETH to borrow
                5, // route
                abi.encode(_targets, _data), // data
                bytes("0x") // extraData
            )
        );

        IDSA(myDSA).cast{value: amt}(spells, datas, address(0));
        // console.log(address(this).balance);
    }
}
