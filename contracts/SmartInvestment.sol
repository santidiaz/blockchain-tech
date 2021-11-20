//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
// import "./Account.sol";

contract SmartInvestment {
    // State variables
    uint256 public auditorsCount;

    Proposal[] private _proposals;
    ProposalData[] private _proposalsData;
    Account[] private _accounts;
    Maker[] private _makers;

    // Mappings
    mapping(address => mapping(Role => bool)) private _roleByAddrs; 
    mapping(address => Account) public accountByAddrs;
    mapping(address => Maker) public makerByAddrs;

    mapping(string => Proposal) public proposalByName;
    mapping(string => ProposalData) private _proposalDataByName;

    // Enums
    enum Role { OWNER, MAKER, VOTER, AUDITOR }
    enum SystemStatus { INACTIVE, NEUTRAL, OPEN_PROPOSALS, VOTING }

    SystemStatus private _systemStatus = SystemStatus.INACTIVE;
    
    // Structs
    struct Account {
        address account;
        Role role;
    }

    struct Maker {
        Account data;
        string name;
        string residence_country;
        uint256 passport_number;
    }

    struct ProposalData {
        string name;
        string description;
        uint256 minAmountRequired; // ethers
        uint256 balance; // ethers
        address maker;
        bool audited;
        bool exists;
    }

    // Address
    address public founder;

    // Events
    event newOwner(address indexed addedBy, address indexed newOwner);
    event newAuditor(address indexed addedBy, address indexed newAuditor);
    event newVoter(address indexed addedBy, address indexed newVoter);
    event newMaker(address indexed addedBy, address indexed newMaker);
    event newProposal(address indexed proposedBy, string proposalName);
    
    event transactionRolledBack(address indexed _from, uint _amount);
    event systemActivated(address indexed _account, string _action);

    // Modifiers
    modifier onlyOwners() {
        require(_roleByAddrs[msg.sender][Role.OWNER] == true, "Not an owner.");
        _;
    }

    modifier onlyMakers() {
        require(_roleByAddrs[msg.sender][Role.MAKER] == true, "Not a maker.");
        _;
    }
    
    modifier onlyAuditor() {
        require(_roleByAddrs[msg.sender][Role.AUDITOR] == true, "Not an auditor.");
        _;
    }

    modifier systemStatusIs(SystemStatus _status) {
        require(_systemStatus == _status, "Action not available.");
        _;
    }
    
    modifier nonZeroAddr(address _targetAddress) {
        require(_targetAddress != address(0), 'Zero address not allowed.');
        _;
    }

    constructor() {
        founder = address(msg.sender);
        _roleByAddrs[founder][Role.OWNER] = true;
        accountByAddrs[founder] = Account(founder, Role.OWNER);
        _accounts.push(accountByAddrs[founder]);

        emit newOwner(address(0), address(msg.sender));
    }

    function getVersion() external pure returns(string memory) {
        return "1.0.0";
    }

    function getSystemStatus() public view returns(string memory currentStatus) {
        if (_systemStatus == SystemStatus.NEUTRAL) {
            currentStatus = "Neutral";
        } else if (_systemStatus == SystemStatus.OPEN_PROPOSALS) {
            currentStatus = "Proposals Period Open";
        } else if (_systemStatus == SystemStatus.VOTING) {
            currentStatus = "Voting Period Open";
        } else if (_systemStatus == SystemStatus.INACTIVE) {
            currentStatus = "Inactive";
        }

        return currentStatus;
    }

    function addOwner(address _newOwnerAddress) external nonZeroAddr(_newOwnerAddress) onlyOwners() {
        require(_roleByAddrs[_newOwnerAddress][Role.OWNER] == false, 'Owner already exists.');

        _roleByAddrs[_newOwnerAddress][Role.OWNER] = true;
        accountByAddrs[_newOwnerAddress] = Account(_newOwnerAddress, Role.OWNER);
        _accounts.push(accountByAddrs[_newOwnerAddress]);

        emit newOwner(msg.sender, _newOwnerAddress);
    }

    function addAuditor(address _newAuditorAddress) external nonZeroAddr(_newAuditorAddress) onlyOwners() {
        require(_roleByAddrs[_newAuditorAddress][Role.AUDITOR] == false, 'Auditor already exists.');

        _roleByAddrs[_newAuditorAddress][Role.AUDITOR] = true;
        accountByAddrs[_newAuditorAddress] = Account(_newAuditorAddress, Role.AUDITOR);
        _accounts.push(accountByAddrs[_newAuditorAddress]);
        auditorsCount++;

        emit newAuditor(msg.sender, _newAuditorAddress);

        activateSystem('addAuditor');
    }

    function addMaker(address _newMakerAddress, string memory _name, string memory _residenceCountry, uint256 _passportNumber) external nonZeroAddr(_newMakerAddress) onlyOwners() {
        require(_roleByAddrs[_newMakerAddress][Role.MAKER] == false, 'Maker already exists.');

        _roleByAddrs[_newMakerAddress][Role.MAKER] = true;
        accountByAddrs[_newMakerAddress] = Account(_newMakerAddress, Role.MAKER);
        makerByAddrs[_newMakerAddress] = Maker(accountByAddrs[_newMakerAddress], _name, _residenceCountry, _passportNumber);

        _accounts.push(accountByAddrs[_newMakerAddress]);
        _makers.push(makerByAddrs[_newMakerAddress]);

        emit newMaker(msg.sender, _newMakerAddress);
        
        activateSystem('addMaker');
    }

    function activateSystem(string memory _action) private {
        // if (_systemStatus == SystemStatus.INACTIVE && auditorsCount > 1 && _makers.length > 2) {
        if (_systemStatus == SystemStatus.INACTIVE && auditorsCount > 0 && _makers.length > 0) {
            _systemStatus = SystemStatus.NEUTRAL;
            emit systemActivated(msg.sender, _action);
        }
    }

    /*function addVoter(address _newVoterAddress) external {
        require(_newVoterAddress != address(0), 'ERC20: approve from the zero address');
        require(_roleByAddrs[_newVoterAddress][Account.Role.VOTER] == false, 'Voter already exists.');

        _roleByAddrs[_newVoterAddress][Account.Role.VOTER] = true;
        _voters.push(_newVoterAddress);
        emit newVoter(msg.sender, _newVoterAddress);
    }*/

    function openProposalsPeriod() external systemStatusIs(SystemStatus.NEUTRAL) onlyOwners() {
        _systemStatus = SystemStatus.OPEN_PROPOSALS;
    }

    function closeProposalsPeriod() external systemStatusIs(SystemStatus.OPEN_PROPOSALS) onlyOwners() {
        _systemStatus = SystemStatus.VOTING;
        
        
        // Encontrarse abierto el periodo de propuestas
        // Deben haber sido presentadas al menos 2 propuestas
    }

    function addProposal(string memory _name, string memory _description, uint256 _minInvestment) external systemStatusIs(SystemStatus.OPEN_PROPOSALS) onlyMakers() {
        require(_minInvestment > 5, 'Minimum investment is 5 ETH.');
        require(_proposalDataByName[_name].exists == false, 'Proposal name already exists.');

        _proposalDataByName[_name] = ProposalData(
            _name,
            _description,
            _minInvestment,
            0, // Balance
            address(msg.sender), // Maker
            false, // Audited
            true // Exists
        );
        _proposalsData.push(_proposalDataByName[_name]);

        emit newProposal(address(msg.sender), _name); 
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