// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.4;

import "./interfaces.sol";

contract starters {
    IInstaIndex instaIndex =
        IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    Comptroller troll = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    address myDSA;

    /**
     * @dev makes the dsa
     * @param _owner owner of the new DSA
     */
    function build_myDSA(address _owner) external {
        myDSA = instaIndex.build(_owner, 2, address(0));
    }

    /**
     * @dev to get the collateral factor
     * @param _asset address of the asset we need collateral factor of
     */
    function getCollateralFactor(address _asset)
        internal
        view
        returns (uint256)
    {
        (, uint256 collateralFactorMantissa, ) = troll.markets(_asset);
        return collateralFactorMantissa;
    }

    /**
     * @dev calculate unit for swap logic
     * @param buyAmount the amount of asset (ETH) to buy
     * @param sellAmount the amount of asset (DAI) to sell
     * @param buyDecimal the decimal of asset to buy
     * @param sellDecimal the decimal of asset to sell
     * @param maxSlippage amount of buying asset per unit of selling asset (default = 1)
     */
    function caculateUnitAmt(
        uint256 buyAmount,
        uint256 sellAmount,
        uint256 buyDecimal,
        uint256 sellDecimal,
        uint256 maxSlippage
    ) internal pure returns (uint256) {
        uint256 unitAmt = (buyAmount / (10**buyDecimal)) /
            (sellAmount / (10**sellDecimal));
        unitAmt = unitAmt * ((100 - maxSlippage) / 100);
        unitAmt = unitAmt * (1e18);
        return unitAmt;
    }
}
