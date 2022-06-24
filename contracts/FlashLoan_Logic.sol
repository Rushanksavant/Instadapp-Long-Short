// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./starters.sol";
import "hardhat/console.sol";

contract FlashLoan_Logic is starters {
    constructor() {
        myDSA = instaIndex.build(address(this), 2, address(0));
    }

    /**
     * @dev
     * @title to take a 3x leveraged position on ETH
     * @notice amount of ETH we want to use should be sent via {value: amt}
     * @notice flash loan borrow wETH + deposit eth -> convert the flash loan wETH to ETH -> deposit all ETH to compound -> borrow DAI from compound -> swap DAI for ETH -> convert ETH to wETH -> repay flash loan with fees
     * @notice Compund's price feed is used to get the price of ETH in USD
     */
    function takePosition() external payable {
        uint256 repayAmount = ((msg.value * 2 * 11005) / 10000);

        uint256 amtDAI = (priceFeed.price("ETH") * repayAmount) /
            ((priceFeed.price("DAI"))); // amount of DAI for borrowed amount of wETH
        // console.log(amtDAI);
        // console.log((priceFeed.price("ETH") * repayAmount) / (10**6));

        string[] memory _targets = new string[](6);
        bytes[] memory _data = new bytes[](6);

        bytes4 flashBorrow = bytes4(
            keccak256("flashBorrowAndCast(address,uint256,uint256,bytes,bytes)")
        );
        bytes4 withdrawETH = bytes4(
            keccak256("withdraw(uint256,uint256,uint256)")
        );
        bytes4 depositETH = bytes4(
            keccak256("deposit(uint256,uint256,uint256)")
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
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0x6B175474E89094C44Da98b954EedeAC495271d0F,
                amtDAI, // amount of DAI to swap
                caculateUnitAmt(repayAmount, amtDAI, 18, 18, 1),
                0,
                0
            )
        );

        (_targets[4], _data[4]) = (
            "WETH-A",
            abi.encodeWithSelector(depositETH, repayAmount, 0, 0)
        );

        (_targets[5], _data[5]) = (
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
