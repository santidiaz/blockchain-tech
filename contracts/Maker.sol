// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Account.sol";

contract Maker is Account {
    // State variables
    string public name;
    string public residence_country;
    uint256 public passport_number;
    
    // Constructor
    constructor(string memory _name, string memory _residence_country, uint256 _passport_number) {
        name = _name;
        residence_country = _residence_country;
        passport_number = _passport_number;
    }

}
