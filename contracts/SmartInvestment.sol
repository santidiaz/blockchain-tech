//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
// import "./Owner.sol";
import "./Account.sol";

contract SmartInvestment {
    // State variables
    Proposal[] private _proposals;
    Account[] private _owners;
    address public founder;

    // Mappings
    // mapping(address => Auditors) public _auditors;
    mapping(address => mapping(Account.Role => bool)) private _addressByRole;
    mapping(address => Account) private _addressByAccount;
    
    // Enums

    // Structs

    // Address

    // Events

    // Modifiers
    modifier onlyOwners() {
        require(_addressByRole[msg.sender][Account.Role.OWNER] == true, "Not an owner.");
        _;
    }

    constructor() {
        Account foundersAccount = new Account(msg.sender, Account.Role.OWNER);

        founder = msg.sender;
        _addressByRole[msg.sender][Account.Role.OWNER] = true; // Retorna true si el address existe para el role indicado.

        _addressByAccount[msg.sender] = foundersAccount;
        _owners.push(foundersAccount);
    }

    function getVersion() external pure returns(string memory) {
        return "1.0.0";
    }

    // Q: Como hacemos para devolver array de addresses? o tupla address/rol
    function getOwners() public view returns(Account[] memory) {
        return _owners;
    }

    function ownersCount() public view returns(uint256) {
        return _owners.length;
    }

    function addOwner(address _newOwnerAddress) external onlyOwners() {
        require(_newOwnerAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newOwnerAddress][Account.Role.OWNER] == false, 'Owner already exists.');

        Account newAccount = new Account(_newOwnerAddress, Account.Role.OWNER);

        _addressByRole[_newOwnerAddress][Account.Role.OWNER] = true;
        _addressByAccount[_newOwnerAddress] = newAccount;
        _owners.push(newAccount);
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