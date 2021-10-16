//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./ParentContract.sol";

contract ChildContract is ParentContract {
    uint256 public myvariable;

    constructor() {

    }

    function getVersion() external pure override returns(string memory) {
        return "1.0.0";
    }
}