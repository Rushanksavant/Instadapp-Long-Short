// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./starters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// deposit eth
// get weth flashloan
// convert it to eth
// deposit all eth to compound
// borrow dai
// swap for weth
// repay flash loan

contract sample is starters {
    constructor() {
        myDSA = instaIndex.build(address(this), 2, address(0));
    }

    function takePosition() external payable {
        uint256 repayAmount = ((msg.value * 2 * 10005) / 10000);

        uint256 amtDAI = (priceFeed.price("ETH") * repayAmount) / (10**6); // amount of DAI for borrowed amount of wETH

        string[] memory _targets = new string[](5);
        bytes[] memory _data = new bytes[](5);

        bytes4 flashBorrow = bytes4(
            keccak256("flashBorrowAndCast(address,uint256,uint256,bytes,bytes)")
        );
        bytes4 withdrawETH = bytes4(
            keccak256("withdraw(uint256,uint256,uint256)")
        );
        bytes4 compoundDeposit = bytes4(
            keccak256("deposit(string,uint256,uint256,uint256)")
        );
        bytes4 compoundBorrow = bytes4(
            keccak256("borrow(string,uint256,uint256,uint256)")
        );
        bytes4 uniswapV2 = bytes4(
            keccak256("sell(address,address,uint256,uint256,uint256,uint256)")
        );
        bytes4 flashPayback = bytes4(
            keccak256("flashPayback(address,uint256,uint256,uint256)")
        );

        // spells other than flashBorrow
        (_targets[0], _data[0]) = (
            "WETH-A",
            abi.encodeWithSelector(withdrawETH, msg.value * 2, 0, 0)
        );

        (_targets[1], _data[1]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(
                compoundDeposit,
                "ETH-A",
                msg.value * 3,
                0,
                0
            )
        );
        (_targets[2], _data[2]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(compoundBorrow, "DAI-A", amtDAI, 0, 0)
        );

        (_targets[3], _data[3]) = (
            "UNISWAP-V2-A",
            abi.encodeWithSelector(
                uniswapV2,
                0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
                0x6B175474E89094C44Da98b954EedeAC495271d0F,
                amtDAI, // amount of DAI to swap
                caculateUnitAmt(msg.value * 2, amtDAI, 18, 18, 1),
                0,
                0
            )
        );

        (_targets[4], _data[4]) = (
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
                msg.value * 2, // amount of wETH to borrow
                5, // route
                abi.encode(_targets, _data), // data
                bytes("0x") // extraData
            )
        );

        IDSA(myDSA).cast{value: msg.value}(spells, datas, address(0));
    }
}
