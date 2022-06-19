// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// interface IInstaIndex {
//     function build(
//         address _owner,
//         uint256 _accountVersion,
//         address _origin
//     ) external returns (address _account);
// }

// interface IDSA {
//     function cast(
//         string[] calldata _targetNames,
//         bytes[] calldata _datas,
//         address _origin
//     ) external payable returns (bytes32);
// }

// contract Task1 {
//     IInstaIndex instaIndex =
//         IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
//     address myDSA;

//     /**
//      * @dev makes the dsa
//      * @param _owner owner of the new DSA
//      */
//     function build_myDSA(address _owner) external {
//         myDSA = instaIndex.build(_owner, 2, address(0));
//     }

//     /**
//      * @dev calculate unit for swap logic
//      * @param buyAmount the amount of asset (ETH) to buy
//      * @param sellAmount the amount of asset (DAI) to sell
//      * @param buyDecimal the decimal of asset to buy
//      * @param sellDecimal the decimal of asset to sell
//      * @param maxSlippage amount of buying asset per unit of selling asset (default = 1)
//      */
//     function caculateUnitAmt(
//         uint256 buyAmount,
//         uint256 sellAmount,
//         uint256 buyDecimal,
//         uint256 sellDecimal,
//         uint256 maxSlippage
//     ) {
//         uint256 unitAmt = (buyAmount / (10**buyDecimal)) /
//             (sellAmount / (10**sellDecimal));
//         unitAmt = unitAmt * ((100 - maxSlippage) / 100);
//         unitAmt = unitAmt * (1e18);
//         return unitAmt;
//     }

//     /**
//      * @dev build spells and cast to go long on ETH
//      * @param _amt amount of ETH to deposit (1ETH = 1e18)
//      * @notice the borrow is set to 50% of _amt, can be changed based on collateral factor
//      */
//     function goLong(uint256 _amt) external payable {
//         require(
//             myDSA != address(0),
//             "DSA address not set, please use build_myDSA"
//         );

//         string[] memory _targets = new string[](11);
//         bytes[] memory _data = new bytes[](11);

//         _targets[0] = "BASIC-A"; // DEPOSIT
//         _targets[1] = "COMPOUND-A"; // deposit
//         _targets[2] = "COMPOUND-A"; // borrow
//         _targets[3] = "UNISWAP-V2-A"; // swap

//         _targets[4] = "COMPOUND-A"; // deposit
//         _targets[5] = "COMPOUND-A"; // borrow
//         _targets[6] = "UNISWAP-V2-A"; // swap

//         _targets[7] = "COMPOUND-A"; // deposit
//         _targets[8] = "COMPOUND-A"; // borrow
//         _targets[9] = "UNISWAP-V2-A"; // swap

//         _targets[10] = "COMPOUND-A"; // deposit

//         bytes4 basicDeposit = bytes4(
//             keccak256("deposit(address,uint256,uint256,uint256)")
//         );
//         bytes4 compoundDeposit1 = bytes4(
//             keccak256("deposit(string,uint256,uint256,uint256)")
//         );
//         bytes4 compoundBorrow1 = bytes4(
//             keccak256("borrow(string,uint256,uint256,uint256)")
//         );
//         bytes4 uniswap_swap1 = bytes4(
//             keccak256("sell(address,address,uint256,uint256,uint256,uint256)")
//         );

//         bytes4 compoundDeposit2 = bytes4(
//             keccak256("deposit(string,uint256,uint256,uint256)")
//         );
//         bytes4 compoundBorrow2 = bytes4(
//             keccak256("borrow(string,uint256,uint256,uint256)")
//         );
//         bytes4 uniswap_swap2 = bytes4(
//             keccak256("sell(address,address,uint256,uint256,uint256,uint256)")
//         );

//         bytes4 compoundDeposit3 = bytes4(
//             keccak256("deposit(string,uint256,uint256,uint256)")
//         );
//         bytes4 compoundBorrow3 = bytes4(
//             keccak256("borrow(string,uint256,uint256,uint256)")
//         );
//         bytes4 uniswap_swap3 = bytes4(
//             keccak256("sell(address,address,uint256,uint256,uint256,uint256)")
//         );

//         bytes4 compoundDeposit4 = bytes4(
//             keccak256("deposit(string,uint256,uint256,uint256)")
//         );

//         address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
//         address dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

//         _data[0] = abi.encodeWithSelector(basicDeposit, eth, _amt, 0, 0);
//         _data[1] = abi.encodeWithSelector(
//             compoundDeposit1,
//             "ETH-A",
//             _amt,
//             0,
//             0
//         );
//         _data[2] = abi.encodeWithSelector(
//             compoundBorrow1,
//             "ETH-A",
//             _amt / 2,
//             0,
//             0
//         );
//         uint256 unit1 = caculateUnitAmt(
//             buyAmount,
//             sellAmount,
//             buyDecimal,
//             sellDecimal,
//             maxSlippage
//         );
//         _data[3] = abi.encodeWithSelector(
//             uniswap_swap1,
//             eth,
//             dai,
//             _amt / 2,
//             unit1,
//             0,
//             0
//         );

//         _data[4] = abi.encodeWithSelector(
//             compoundDeposit2,
//             "ETH-A",
//             _amt / 2,
//             0,
//             0
//         );
//         _data[5] = abi.encodeWithSelector(
//             compoundBorrow2,
//             "ETH-A",
//             _amt / 4,
//             0,
//             0
//         );
//         uint256 unit2 = caculateUnitAmt(
//             buyAmount,
//             sellAmount,
//             buyDecimal,
//             sellDecimal,
//             maxSlippage
//         );
//         _data[6] = abi.encodeWithSelector(
//             uniswap_swap2,
//             eth,
//             dai,
//             _amt / 4,
//             unit2,
//             0,
//             0
//         );

//         _data[7] = abi.encodeWithSelector(
//             compoundDeposit3,
//             "ETH-A",
//             _amt / 4,
//             0,
//             0
//         );
//         _data[8] = abi.encodeWithSelector(
//             compoundBorrow3,
//             "ETH-A",
//             _amt / 8,
//             0,
//             0
//         );
//         uint256 unit3 = caculateUnitAmt(
//             buyAmount,
//             sellAmount,
//             buyDecimal,
//             sellDecimal,
//             maxSlippage
//         );
//         _data[9] = abi.encodeWithSelector(
//             uniswap_swap2,
//             eth,
//             dai,
//             _amt / 8,
//             unit3,
//             0,
//             0
//         );

//         _data[10] = abi.encodeWithSelector(
//             compoundDeposit4,
//             "ETH-A",
//             _amt / 8,
//             0,
//             0
//         );

//         IDSA(myDSA).cast(_targets, _data, address(0))
//     }
// }
