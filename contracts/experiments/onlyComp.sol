// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "../starters.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract onlyComp is starters {
    constructor() {
        myDSA = instaIndex.build(address(this), 2, address(0));
    }

    function takePosition() external payable {
        uint256 amtDAI = ((priceFeed.price("ETH") *
            2000000000000000000 *
            10005) / 10000) / ((priceFeed.price("DAI")));

        string[] memory _targets = new string[](4);
        bytes[] memory _data = new bytes[](4);

        bytes4 compoundDeposit = bytes4(
            keccak256("deposit(string,uint256,uint256,uint256)")
        );
        bytes4 compoundBorrow = bytes4(
            keccak256("borrow(string,uint256,uint256,uint256)")
        );
        bytes4 uniswapV2 = bytes4(
            keccak256("sell(address,address,uint256,uint256,uint256,uint256)")
        );
        bytes4 depositETH = bytes4(
            keccak256("deposit(uint256,uint256,uint256)")
        );

        // spells other than flashBorrow
        (_targets[0], _data[0]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(compoundDeposit, "ETH-A", msg.value, 0, 0)
        );
        (_targets[1], _data[1]) = (
            "COMPOUND-A",
            abi.encodeWithSelector(compoundBorrow, "DAI-A", amtDAI, 0, 0)
        );

        (_targets[2], _data[2]) = (
            "UNISWAP-V2-A",
            abi.encodeWithSelector(
                uniswapV2,
                0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE,
                0x6B175474E89094C44Da98b954EedeAC495271d0F,
                amtDAI, // amount of DAI to swap
                caculateUnitAmt(
                    (2000000000000000000 * 10005) / 10000,
                    amtDAI,
                    18,
                    18,
                    1
                ),
                0,
                0
            )
        );
        (_targets[3], _data[3]) = (
            "WETH-A",
            abi.encodeWithSelector(
                depositETH,
                (2000000000000000000 * 10005) / 10000,
                0,
                0
            )
        );

        IDSA(myDSA).cast{value: msg.value}(_targets, _data, address(0));
    }
}
