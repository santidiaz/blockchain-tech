// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Account.sol";

contract Maker is Account {
    // State variables
    string public name;
    string public residence_country;
    uint256 public passport_number;
    
    // Constructor
    constructor() {
    }
}
