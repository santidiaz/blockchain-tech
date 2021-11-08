//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
// import "./Owner.sol";
import "./Account.sol";

contract SmartInvestment {
    // State variables
    address public founder;
    address[] private _owners;
    Proposal[] private _proposals;

    // Mappings
    mapping(address => mapping(Account.Role => bool)) private _addressByRole;
    mapping(address => Account) private _addressByAccount;

    // Enums
    enum SystemStatus { INACTIVE, NEUTRAL, OPEN_PROPOSALS, VOTING }
    SystemStatus systemStatus = SystemStatus.INACTIVE;

    // Structs

    // Address

    // Events
    event founderSet(address indexed newFounder);
    event newOwner(address indexed addedBy, address indexed newOwner);

    // Modifiers
    modifier onlyOwners() {
        require(_addressByRole[msg.sender][Account.Role.OWNER] == true, "Not an owner.");
        _;
    }

    constructor() {
        founder = address(msg.sender);
        emit founderSet(founder);

        _addressByRole[founder][Account.Role.OWNER] = true; // Retorna true si el address existe para el role indicado.
        _owners.push(founder);
        emit newOwner(address(0), founder);
    }

    function getVersion() external pure returns(string memory) {
        return "1.0.0";
    }

    function getOwners() external view returns(address[] memory) {
        return _owners;
    }

    function isOwner(address _ownerAddress) external view returns(bool) {
        return _addressByRole[_ownerAddress][Account.Role.OWNER];
    }

    function getSystemStatus() public view returns(string memory currentStatus) {
        if (systemStatus == SystemStatus.NEUTRAL) {
            currentStatus = "Neutral";
        } else if (systemStatus == SystemStatus.OPEN_PROPOSALS) {
            currentStatus = "Proposals Period Open";
        } else if (systemStatus == SystemStatus.VOTING) {
            currentStatus = "Voting Period Open";
        } else if (systemStatus == SystemStatus.INACTIVE) {
            currentStatus = "Inactive";
        }

        return currentStatus;
    }

    function addOwner(address _newOwnerAddress) external onlyOwners() {
        require(_newOwnerAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newOwnerAddress][Account.Role.OWNER] == false, 'Owner already exists.');

        _addressByRole[_newOwnerAddress][Account.Role.OWNER] = true;
        _owners.push(_newOwnerAddress);
        emit newOwner(msg.sender, _newOwnerAddress);
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