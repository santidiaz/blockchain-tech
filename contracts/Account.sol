// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Account {
    // State variables
    Rol private _rol;

    // Mappings
    
    // Enums
    enum Rol {
        OWNER,
        MAKER,
        VOTER,
        AUDITOR
    }
    
    // Structs

    // Address
    address private _owner;

    // Events
    event transferToken(address indexed _from, address indexed _to, uint256 _amount);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the owner.");
        _;
    }

    modifier balance(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    // Constructor
    constructor(uint inputRol, address _account) {
        // Initialization
        _owner = _account;
        _rol = inputRol;
        // TODO: Log this with emit
    }
    
    // Functions
    function getRole() public onlyOwner() {
        // return "Owner role";
    }

    function getOwner() external view returns(address) {
        return _owner;
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
