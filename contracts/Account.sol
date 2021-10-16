// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Account {
    // State variables
    string public rol;

    // Mappings
    
    // Enums
    
    // Structs

    // Address
    address payable public owner;
    address private _myAddress;

    // Events
    event transferToken(address indexed _from, address indexed _to, uint256 _amount);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner.");
        _;
    }

    modifier balance(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    // Constructor
    constructor() {
        // Initialization
        owner = payable(msg.sender);
    }
    
    // Functions
    function getRole() public onlyOwner() {
        // return "Owner role";
    }

    function getVersion() public pure returns(string memory) {
        return "Version 1.0.0";
    }

    // State [balance, storage, nonce]
    function getBalance() external view returns(uint256) {
        // Otro ejemplo: owner.balance; Q: <this> hace referencia al <owner>? son lo mismo?
        return address(this).balance;
    }

    receive() external payable {
        // revert(); // rollback transaction
        // emit myEvent(); // Ejemplo logear algo.
    }
}
