// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

abstract contract Ownable {
    // State variables
    address private _owner;
    
    // Mappings
    mapping(address => mapping(Role => bool)) internal _roleByAddrs; 
    
    // Enums
    enum Role { OWNER, MAKER, VOTER, AUDITOR }
    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwner() {
        require(getOwner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyRole(Role role) {
        require(_roleByAddrs[msg.sender][role] == true, "Ownable: action is not permitted with role");
        _;
    }

    // Constructor
    constructor() {
        _setOwner(msg.sender);
    }
    
    // Functions
    function getOwner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}
