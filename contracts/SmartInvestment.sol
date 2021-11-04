//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
// import "./Owner.sol";
import "./Account.sol";

contract SmartInvestment {
    // State variables
    Proposal[] private _proposals;
    Account[] private _owners;

    // Mappings
    // mapping(address => Auditors) public _auditors;
    mapping(address => Account) private _ownerByAddress; // Q: Capaz que podemos filtrar por rol?
    
    // Enums
    
    // Structs

    // Address

    // Events
    event ownerSet(address indexed oldOwner, address indexed newOwner);

    // Modifiers
    modifier onlyOwners() {
        require(_ownerByAddress[msg.sender], "Not an owner.");
        _;
    }

    constructor() {
        _owners.push(Account(msg.sender));
        emit ownerSet(address(0), _owners[]);
    }

    function getVersion() external pure returns(string memory) {
        return "1.0.0";
    }

    // <view> porque va a leer de la blockchain.
    // No <external> porque puede ser leeido desde adentro del contrato tambien.
    function getProposalsCount() public view returns(uint256) {
        return _proposals.length;
    }

    function getProposals() public view returns(Proposal[] memory) {
        return _proposals;
    }


    // function openProposalSubmissionPeriod

    // function closeProposalSubmissionPeriod {
        // openVotingPeriod
    // }
    
    // function submitProposal() 

    // 
}