// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Account {
    // State variables

    // Mappings
    mapping(Role => MemberData) private _roles;

    // Enums
    enum Role { OWNER, MAKER, VOTER, AUDITOR }
    
    // Structs
    struct MemberData {
        mapping(address => bool) members;
        Role role;
    }

    // Address
    // address public ownerAddress;

    // Events
    event transferToken(address indexed _from, address indexed _to, uint256 _amount);
    event accountSet(address indexed _from, address indexed _to, uint256 _role);
    
    // Modifiers
    /*modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Not the owner.");
        _;
    }*/

    modifier balance(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }

    // Constructor
    /*constructor(address _ownerAddress, Role _role) {
        ownerAddress = _ownerAddress;
        role = _role;
        emit accountSet(address(0), ownerAddress, uint256(_role));
    }*/
    
    // Functions
    function getVersion() public pure returns(string memory) {
        return "Version 1.0.0";
    }

    // State [balance, storage, nonce]
    function getBalance() external view returns(uint256) {
        // Otro ejemplo: owner.balance; Q: <this> hace referencia al <owner>? son lo mismo?
        return address(this).balance;
    }
    
    
    function hasRole(Role _role, address _account) private view returns (bool) {
        return _roles[_role].members[_account];
    }

    receive() external payable {
        // revert(); // rollback transaction
        // emit myEvent(); // Ejemplo logear algo.
    }
}
