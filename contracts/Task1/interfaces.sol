// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

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

interface Comptroller {
    function markets(address)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );
}
