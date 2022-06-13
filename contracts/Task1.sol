// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IInstaIndex {
    function build(
        address _owner,
        uint256 _accountVersion,
        address _origin
    ) external returns (address _account);
}

interface IDSA {
    function cast(
        string[] calldata _targetNames,
        bytes[] calldata _datas,
        address _origin
    ) external payable returns (bytes32);
}

contract Task1 {
    IInstaIndex instaIndex =
        IInstaIndex(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);
    address myDSA;

    /**
     * @dev makes the dsa
     * @param _owner owner of the new DSA
     */
    function build_myDSA(address _owner) external {
        myDSA = instaIndex.build(_owner, 2, address(0));
    }

    /**
     * @dev build spells and cast to go long on ETH
     * @param _amt amount of ETH to deposit (1ETH = 1e18)
     * @notice the borrow is set to 50% of _amt, can be changed based on collateral factor
     */
    function goLong(uint256 _amt) external payable {
        require(
            myDSA != address(0),
            "DSA address not set, please use build_myDSA"
        );

        string[] memory _targets = new string[](3);
        bytes[] memory _data = new bytes[](3);

        _targets[0] = "BASIC-A";
        _targets[1] = "COMPOUND-A";
        _targets[2] = "COMPOUND-A";

        bytes4 basicDeposit = bytes4(
            keccak256("deposit(address,uint256,uint256,uint256)")
        );
        bytes4 compoundDeposit = bytes4(
            keccak256("deposit(string,uint256,uint256,uint256)")
        );
        bytes4 compoundBorrow = bytes4(
            keccak256("borrow(string,uint256,uint256,uint256)")
        );
        address eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

        _data[0] = abi.encodeWithSelector(basicDeposit, eth, _amt, 0, 0);
        _data[1] = abi.encodeWithSelector(compoundDeposit, "ETH-A", _amt, 0, 0);
        _data[2] = abi.encodeWithSelector(
            compoundBorrow,
            "ETH-A",
            _amt / 2,
            0,
            0
        );

        IDSA(myDSA).cast(_targets, _data, address(0));
    }
}
