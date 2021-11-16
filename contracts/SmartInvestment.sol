//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
import "./Account.sol";

contract SmartInvestment {
    // State variables
    address public founder;
    address[] private _owners;
    address[] private _makers;
    address[] private _auditors;
    Proposal[] public proposals;
    ProposalData[] private _proposalsData;

    // Mappings
    mapping(address => mapping(Account.Role => bool)) private _addressByRole;
    mapping(bytes32 => Proposal) private _proposalByName;
    mapping(bytes32 => ProposalData) private _proposalDataByName;

    // Enums
    enum SystemStatus { INACTIVE, NEUTRAL, OPEN_PROPOSALS, VOTING }
    SystemStatus systemStatus = SystemStatus.INACTIVE;

    // Structs
    struct ProposalData {
        bytes32 name;
        string description;
        uint256 minAmountRequired; // ethers
        uint256 balance; // ethers
        address maker;
        bool audited;
        bool exists;
    }

    // Address

    // Events
    event founderSet(address indexed newFounder);
    event newOwner(address indexed addedBy, address indexed newOwner);
    event newAuditor(address indexed addedBy, address indexed newAuditor);
    event newVoter(address indexed addedBy, address indexed newVoter);
    event newMaker(address indexed addedBy, address indexed newMaker);
    event newProposal(address indexed proposedBy, bytes32 proposalName);
    
    event transactionRolledBack(address indexed _from, uint _amount);
    event systemActivated(address indexed _account, bytes32 _action);

    // Modifiers
    modifier onlyOwners() {
        require(_addressByRole[msg.sender][Account.Role.OWNER] == true, "Not an owner.");
        _;
    }

    modifier onlyMakers() {
        require(_addressByRole[msg.sender][Account.Role.MAKER] == true, "Not a maker.");
        _;
    }
    
    modifier onlyAuditor() {
        require(_addressByRole[msg.sender][Account.Role.AUDITOR] == true, "Not an auditor.");
        _;
    }

    modifier systemActive() {
        require(systemStatus == SystemStatus.NEUTRAL, "System unavailable.");
        _;
    }
    
    modifier nonZeroAddr(address _targetAddress) {
        require(_targetAddress != address(0), 'Zero address not allowed.');
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

    function addOwner(address _newOwnerAddress) external nonZeroAddr(_newOwnerAddress) onlyOwners() {
        require(_addressByRole[_newOwnerAddress][Account.Role.OWNER] == false, 'Owner already exists.');

        _addressByRole[_newOwnerAddress][Account.Role.OWNER] = true;
        _owners.push(_newOwnerAddress);
        emit newOwner(msg.sender, _newOwnerAddress);
    }

    function addAuditor(address _newAuditorAddress) external nonZeroAddr(_newAuditorAddress) onlyOwners() {
        require(_addressByRole[_newAuditorAddress][Account.Role.AUDITOR] == false, 'Auditor already exists.');

        _addressByRole[_newAuditorAddress][Account.Role.AUDITOR] = true;
        _auditors.push(_newAuditorAddress);
        emit newAuditor(msg.sender, _newAuditorAddress);

        activateSystem('addAuditor');
    }

    function addMaker(address _newMakerAddress) external nonZeroAddr(_newMakerAddress) onlyOwners() {
        require(_addressByRole[_newMakerAddress][Account.Role.MAKER] == false, 'Maker already exists.');

        _addressByRole[_newMakerAddress][Account.Role.MAKER] = true;
        _makers.push(_newMakerAddress);
        emit newMaker(msg.sender, _newMakerAddress);
        
        activateSystem('addMaker');
    }

    function activateSystem(bytes32 _action) private {
        if (systemStatus == SystemStatus.INACTIVE && _auditors.length > 1 && _makers.length > 2) {
            systemStatus = SystemStatus.NEUTRAL;
            emit systemActivated(msg.sender, _action);
        }
    }

    /*function addVoter(address _newVoterAddress) external {
        require(_newVoterAddress != address(0), 'ERC20: approve from the zero address');
        require(_addressByRole[_newVoterAddress][Account.Role.VOTER] == false, 'Voter already exists.');

        _addressByRole[_newVoterAddress][Account.Role.VOTER] = true;
        _voters.push(_newVoterAddress);
        emit newVoter(msg.sender, _newVoterAddress);
    }*/

    function openProposalsPeriod() external systemActive() onlyOwners() {
        systemStatus = SystemStatus.OPEN_PROPOSALS;
    }

    function closeProposalsPeriod() external onlyOwners() {
        require(systemStatus == SystemStatus.OPEN_PROPOSALS, 'Not allowed, proposals period not open.');

        systemStatus = SystemStatus.VOTING;
        // Encontrarse abierto el periodo de propuestas
        // Deben haber sido presentadas al menos 2 propuestas
    }

    function addProposal(bytes32 _name, string memory _description, uint32 _minInvestment) external systemActive() onlyMakers() {
        require(systemStatus == SystemStatus.OPEN_PROPOSALS, 'Not allowed, proposals period not open.');
        require(_minInvestment > 5, 'Minimum investment is 5 ETH.');
        require(_proposalDataByName[_name].exists == true, 'Proposal name already exists.');

        ProposalData memory proposalData = ProposalData({
            name: _name,
            description: _description,
            minAmountRequired: _minInvestment,
            balance: 0,
            maker: msg.sender,
            audited: false,
            exists: true
        });
        _proposalsData.push(proposalData);
        _proposalDataByName[proposalData.name] = proposalData;

        emit newProposal(proposalData.maker, _name); 
    }
    
    /*function auditProposal(uint32 _proposalIndex, address _auditor) external systemActive() onlyAuditor() {
        require(systemStatus == SystemStatus.OPEN_PROPOSALS, 'Not allowed, proposals period not open.');
        require(_proposalsData.length > 0, 'No proposals for audit.');
        require(__proposalsForReview)

        _proposalsData.push(Proposal.Data({
            name: _name,
            description: _description,
            minAmountRequired: _minInvestment,
            balance: 0,
            maker: msg.sender
        }));
        // TODO: emit proposal created
    }*/

    // function openProposalSubmissionPeriod

    // function closeProposalSubmissionPeriod isOwner() {
        // openVotingPeriod
    // }
    
    // function submitProposal() isAvailableForProposalAndVote()

    // 
    
    /**
     * @dev Logs senders address and amount (wei sent), then rollback transaction
     */
    receive() external payable {
        emit transactionRolledBack(msg.sender, msg.value);
        revert();
    }
}