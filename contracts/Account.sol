// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Account {
    // State variables

    // Mappings
    mapping(Role => MemberData) private _memberByRole;

    // Enums
    enum Role { OWNER, MAKER, VOTER, AUDITOR }
    
    // Structs
    struct MemberData {
        mapping(address => bool) members;
        Role role;
    }

    // Address

    // Events
    event accountSet(address indexed _from, address indexed _to, uint256 _role);
    
    // Modifiers
    modifier balance(uint256 _amount) {
        require(address(this).balance >= _amount);
        _;
    }
    
    // Functions
    
    function hasRole(Role _role, address _account) internal view returns (bool) {
        return _memberByRole[_role].members[_account];
    }
}
