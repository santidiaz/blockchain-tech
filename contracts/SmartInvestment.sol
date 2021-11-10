//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
// import "./Owner.sol";
import "./Account.sol";

contract SmartInvestment {
    // State variables
    address public founder;
    address[] private _owners;
    address[] private _auditors;
    address[] private _voters;
    address[] private _makers;
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
    event newAuditor(address indexed addedBy, address indexed newAuditor);
    event newVoter(address indexed addedBy, address indexed newVoter);
    event newMaker(address indexed addedBy, address indexed newMaker);

    // Modifiers
    modifier onlyOwners() {
        require(_addressByRole[msg.sender][Account.Role.OWNER] == true, "Not an owner.");
        _;
    }

    modifier isAvailableForProposalAndVote() {
        uint256 auditorsCount = getRoleCount(_auditors, Account.Role.AUDITOR);
        uint256 makersCount = getRoleCount(_makers, Account.Role.MAKER);
        require(auditorsCount >= 2 && makersCount >= 3, "Not availabel for proposal and vote.");
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

    function addAuditor(address _newAuditorAddress) external {
        require(_newAuditorAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newAuditorAddress][Account.Role.AUDITOR] == false, 'Auditor already exists.');

        _addressByRole[_newAuditorAddress][Account.Role.AUDITOR] = true;
        _auditors.push(_newAuditorAddress);
        emit newAuditor(msg.sender, _newAuditorAddress);
    }

    function addMaker(address _newMakerAddress) external {
        require(_newMakerAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newMakerAddress][Account.Role.MAKER] == false, 'Maker already exists.');

        _addressByRole[_newMakerAddress][Account.Role.MAKER] = true;
        _makers.push(_newMakerAddress);
        emit newMaker(msg.sender, _newMakerAddress);
    }

    function addVoter(address _newVoterAddress) external {
        require(_newVoterAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newVoterAddress][Account.Role.VOTER] == false, 'Voter already exists.');

        _addressByRole[_newVoterAddress][Account.Role.VOTER] = true;
        _voters.push(_newVoterAddress);
        emit newVoter(msg.sender, _newVoterAddress);
    }

    // <view> porque va a leer de la blockchain.
    // No <external> porque puede ser leeido desde adentro del contrato tambien.
    function getProposalsCount() public view returns(uint256) {
        return _proposals.length;
    }

    function getProposals() public view returns(Proposal[] memory) {
        return _proposals;
    }

    function getRoleCount(address[] memory _addresses, Account.Role _role) public view returns(uint256) {
        uint addressesLength = _addresses.length;
        uint count = 0;
        for (uint i=0; i < addressesLength; i++) {
           if (_addressByRole[_addresses[i]][_role]) {
            count ++;
           }
        }
        return count;
    }

    // function openProposalSubmissionPeriod

    // function closeProposalSubmissionPeriod {
        // openVotingPeriod
    // }
    
    // function submitProposal() isAvailableForProposalAndVote()

    // 
}