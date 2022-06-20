// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

import "./starters.sol";

contract flashLoanLogic is starters {
    /**
     * @dev
     * @title to take a 3x leveraged position on ETH
     * @param amt the amount of ETH we want to use
     * @notice flash loan borrow eth -> deposit eth in compound -> borrow DAI from compound -> swap DAI for ETH on uniswap -> repay flash loan
     * @notice Compund's price feed is used to get the price of ETH in USD
     */
    function takePosition(uint256 amt) external payable {
        // uint256 collateralFactor = getCollateralFactor(asset);

        uint256 amtDAI = (priceFeed.price("ETH") * amt * 2) / (10**6); // amount of DAI for borrowed amount of ETH

        string[] memory _targets = new string[](5);
        bytes[] memory _data = new bytes[](5);

        bytes4 flashBorrow = bytes4(
            keccak256(
                "flashBorrowAndCast(address,uint256,uint256,bytes32,bytes32)"
            )
        );
        bytes4 basicDeposit = bytes4(
            keccak256("deposit(address,uint256,uint256,uint256)")
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
            "BASIC-A",
            abi.encodeWithSelector(
                basicDeposit,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                amt * 3,
                0,
                0
            )
        );
        (_targets[1], _data[1]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(compoundDeposit, "ETH-A", amt * 3, 0, 0)
        );
        (_targets[2], _data[2]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(
                compoundBorrow,
                "DAI-A",
                amtDAI, // amount of DAI to borrow
                0,
                0
            )
        );
        (_targets[3], _data[3]) = (
            "UNISWAP-V2-A",
            abi.encodeWithSelector(
                uniswapV2,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0x6B175474E89094C44Da98b954EedeAC495271d0F,
                amtDAI, // amount of DAI to swap, to get amt*2 amount of ETH
                caculateUnitAmt(amt * 2, amtDAI, 18, 18, 1),
                0,
                0
            )
        );
        (_targets[4], _data[4]) = (
            "INSTAPOOL-C",
            abi.encodeWithSelector(
                flashPayback,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                amt * 2,
                0,
                0
            )
        );

        // flashBorrow spell
        string[] memory spells = new string[](1);
        bytes[] memory datas = new bytes[](1);

        (_targets[0], _data[0]) = (
            "INSTAPOOL-C",
            abi.encodeWithSelector(
                flashBorrow,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, // token
                amt * 2, // amount of ETH to borrow
                1, // route
                abi.encode(spells, datas), // data
                bytes("0x") // extraData
            )
        );

        IDSA(myDSA).cast(_targets, _data, address(0));
    }
}
