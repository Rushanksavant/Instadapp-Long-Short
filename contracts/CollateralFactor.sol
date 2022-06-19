// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

import "./starters.sol";
import "hardhat/console.sol";

contract usingCollateralFactor is starters {
    mapping(uint256 => uint256) loopNum_Borrow;
    uint256 operationNums;

    function calculateLoops(uint256 originalDeposit, address _asset) internal {
        uint256 collateralFactor = getCollateralFactor(_asset);
        // console.log(collateralFactor);
        uint256 debt = 0;
        uint256 operationLoops = 0;
        uint256 leveragedCollateral = originalDeposit;

        // console.log(leveragedCollateral);
        // console.log(originalDeposit * 3);

        while (originalDeposit * 3 > leveragedCollateral) {
            uint256 newDebt = (leveragedCollateral * collateralFactor) /
                10**18 -
                debt;
            console.log(newDebt);
            debt += newDebt;
            leveragedCollateral += newDebt;

            loopNum_Borrow[operationLoops] = newDebt;

            operationLoops++;
        }
        // console.log(leveragedCollateral);
        // console.log(operationLoops);
        operationNums = operationLoops;
    }

    /**
     * @dev build spells and cast to go long on a particular asset
     * @param _amt amount of asset to deposit (eg: 1ETH = 1e18)
     * @param _asset the asset we want to take leveraged position on
     * @notice the borrow is set to 50% of _amt, can be changed based on collateral factor
     */
    function goLong(uint256 _amt, address _asset) external payable {
        require(
            myDSA != address(0),
            "DSA address not set, please use build_myDSA"
        );

        calculateLoops(_amt, _asset);
        uint256 numSpells = 2 + operationNums * 2;

        string[] memory _targets = new string[](numSpells);
        bytes[] memory _data = new bytes[](numSpells);

        _targets[0] = "BASIC-A"; // DEPOSIT
        _targets[1] = "COMPOUND-A"; // deposit

        bytes4 basicDeposit = bytes4(
            keccak256("deposit(address,uint256,uint256,uint256)")
        );
        bytes4 compoundDeposit1 = bytes4(
            keccak256("deposit(string,uint256,uint256,uint256)")
        );

        _data[0] = abi.encodeWithSelector(basicDeposit, _asset, _amt, 0, 0);
        _data[1] = abi.encodeWithSelector(
            compoundDeposit1,
            "ETH-A",
            _amt,
            0,
            0
        );

        for (uint256 i = 2; i < numSpells; i += 2) {
            _targets[i] = "COMPOUND-A";
            _targets[i + 1] = "COMPOUND-A";

            bytes4 compoundBorrow = bytes4(
                keccak256("borrow(string,uint256,uint256,uint256)")
            );
            bytes4 compoundDeposit = bytes4(
                keccak256("deposit(string,uint256,uint256,uint256)")
            );

            _data[i] = abi.encodeWithSelector(
                compoundBorrow,
                "ETH-A",
                loopNum_Borrow[i - 2],
                0,
                0
            );
            _data[i + 1] = abi.encodeWithSelector(
                compoundDeposit,
                "ETH-A",
                loopNum_Borrow[i - 1],
                0,
                0
            );
        }

        IDSA(myDSA).cast(_targets, _data, address(0));
    }
}
