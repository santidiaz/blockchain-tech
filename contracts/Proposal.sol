// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Proposal {
    // State variables
    string private _name;
    string private _description;
    uint256 private _min_amount_required = 5; // ethers
    uint256 private _balance; // ethers
    Maker private _maker;
    Voter[] private _voters;

    struct Voter {
        bool voted;
        uint256 balance; // Cada vez que vota, se suma el monto aca
        address account;
        uint256 proposalIndex;
    }

    struct Maker {
        string name;
        string residence_country;
        uint256 passport_number;
        address account;
    }

    // - Que la suma de los balances de los contratos de las propuestas hayan alcanzado un mínimo de 50 ethers
    // - Que el cierre sea autorizado por al menos 2 auditors
    uint256 private _votesCount;
    uint256[] private _auditors;
    
    // Mappings
    // mapping(address => Account) private _owners;
    mapping(address => Voter) public voters;

    // Enums

    // Structs

    // Address
    
    // Events
    event makerSet(address indexed newMaker);
    event transferRolledBack(address indexed _from, uint _amount);

    // Modifiers

    // Constructor
    constructor(string memory name, string memory description, Maker memory maker) {
        _name = name;
        _description = description;
        _maker = maker;

        // Q: _maker address? hago un getAddress en Maker?
        // emit makerSet(_maker);
    }
    
    // Functions
    function getName() external view returns(string memory) {
        return _name;
    }

    function getDescription() external view returns(string memory) {
        return _description;
    }


    /**
     * @dev Logs senders address and amount (wei sent), then rollback transaction
     */
    receive() external payable {
        emit transferRolledBack(msg.sender, msg.value);
        revert();
    }
}
