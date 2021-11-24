//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";
import "./Ownable/Ownable.sol";
import "./Pausable/Pausable.sol";

contract SmartInvestment is Ownable, Pausable {
    // State variables
    SystemStatus private _systemStatus = SystemStatus.INACTIVE;
    uint256 public auditorsCount;
    uint256 private _auditedProposalsCount;

    Proposal[] public winningProposals;
    Proposal[] private _proposals;
    Proposal.ProposalData[] private _proposalsData;
    Account[] private _accounts;
    Maker[] private _makers;
    address[] private _votingClosureAuthorizers;

    // Mappings
    mapping(address => Account) public accountByAddrs;
    mapping(address => Maker) public makerByAddrs;

    mapping(string => Proposal) public proposalByName;
    mapping(string => Proposal.ProposalData) private _proposalDataByName;
    mapping(SystemStatus => string) private _systemStatusDescription;

    // Enums
    enum SystemStatus { INACTIVE, NEUTRAL, OPEN_PROPOSALS, VOTING }
    
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

    // Events
    event newAccount(address indexed addedBy, address indexed newAccount, Role assignedRole);
    event newProposal(address indexed proposedBy, string proposalName);
    event transactionRolledBack(address indexed _from, uint _amount);
    event systemActivated(address indexed _account, string _action);

    // Modifiers
    modifier systemStatusIs(SystemStatus _status) {
        require(_systemStatus == _status, "Action unavailable");
        _;
    }
    
    modifier nonZeroAddr(address _targetAddress) {
        require(_targetAddress != address(0), 'Err address');
        _;
    }

    modifier closeVotingAuthorized() {
        require(_votingClosureAuthorizers.length > 1, 'Not enough authorizations');
        _;
    }

    constructor() payable {
        _roleByAddrs[address(msg.sender)][Role.OWNER] = true;
        accountByAddrs[address(msg.sender)] = Account(address(msg.sender), Role.OWNER);
        _accounts.push(accountByAddrs[address(msg.sender)]);

        _systemStatusDescription[SystemStatus.INACTIVE] = "Inactive";
        _systemStatusDescription[SystemStatus.NEUTRAL] = "Neutral";
        _systemStatusDescription[SystemStatus.OPEN_PROPOSALS] = "Proposals Period Open";
        _systemStatusDescription[SystemStatus.VOTING] = "Voting Period Open";

        emit newAccount(address(0), address(msg.sender), Role.OWNER);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addOwner(address _newOwnerAddress) external nonZeroAddr(_newOwnerAddress) whenNotPaused() onlyRole(Role.OWNER) {
        require(_roleByAddrs[_newOwnerAddress][Role.OWNER] == false, 'Owner already exists.');

        _roleByAddrs[_newOwnerAddress][Role.OWNER] = true;
        accountByAddrs[_newOwnerAddress] = Account(_newOwnerAddress, Role.OWNER);
        _accounts.push(accountByAddrs[_newOwnerAddress]);

        emit newAccount(address(msg.sender), _newOwnerAddress, Role.OWNER);
    }

    function addAuditor(address _newAuditorAddress) external nonZeroAddr(_newAuditorAddress) whenNotPaused() onlyRole(Role.OWNER) {
        require(_roleByAddrs[_newAuditorAddress][Role.AUDITOR] == false, 'Auditor already exists.');

        _roleByAddrs[_newAuditorAddress][Role.AUDITOR] = true;
        accountByAddrs[_newAuditorAddress] = Account(_newAuditorAddress, Role.AUDITOR);
        _accounts.push(accountByAddrs[_newAuditorAddress]);
        auditorsCount++;

        emit newAccount(address(msg.sender), _newAuditorAddress, Role.AUDITOR);

        activateSystem('addAuditor');
    }

    function addMaker(address _newMakerAddress, string memory _name, string memory _residenceCountry, uint256 _passportNumber) external nonZeroAddr(_newMakerAddress) whenNotPaused() onlyRole(Role.OWNER) {
        require(_roleByAddrs[_newMakerAddress][Role.MAKER] == false, 'Maker already exists.');

        _roleByAddrs[_newMakerAddress][Role.MAKER] = true;
        accountByAddrs[_newMakerAddress] = Account(_newMakerAddress, Role.MAKER);
        makerByAddrs[_newMakerAddress] = Maker(accountByAddrs[_newMakerAddress], _name, _residenceCountry, _passportNumber);

        _accounts.push(accountByAddrs[_newMakerAddress]);
        _makers.push(makerByAddrs[_newMakerAddress]);

        emit newAccount(address(msg.sender), _newMakerAddress, Role.MAKER);
        
        activateSystem('addMaker');
    }

    function addProposal(string memory _name, string memory _description, uint256 _minInvestment) external whenNotPaused() systemStatusIs(SystemStatus.OPEN_PROPOSALS) onlyRole(Role.MAKER) {
        require(!_proposalDataByName[_name].exists, 'Proposal already exists.');

        _proposalDataByName[_name] = Proposal.ProposalData(
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


    function openProposalsPeriod() external whenNotPaused() systemStatusIs(SystemStatus.NEUTRAL) onlyRole(Role.OWNER) {
        _systemStatus = SystemStatus.OPEN_PROPOSALS;
    }

    function closeProposalsPeriod() external whenNotPaused() systemStatusIs(SystemStatus.OPEN_PROPOSALS) onlyRole(Role.OWNER) {
        require(_auditedProposalsCount > 1, 'Minimun 2 proposal audited required to start voting period.');

        // Itero por las propuestas presentadas.
        for (uint256 p = 0; p < _proposalsData.length; p++) {
            // Si fueron auditadas las instancio.
            if (_proposalDataByName[_proposalsData[p].name].audited) {
                // La agrego al mapping para buscar rapido por nombre
                proposalByName[_proposalsData[p].name] = new Proposal(
                    _proposalsData[p].name,
                    _proposalsData[p].description,
                    _proposalsData[p].maker,
                    _proposalsData[p].minAmountRequired
                );

                // La agrego al array de propuestas instanciadas (Las que ya pueden recibir fondos)
                _proposals.push(proposalByName[_proposalsData[p].name]);
            } else {
                delete _proposalDataByName[_proposalsData[p].name];
            }
        }

        // Reseteo algunas variables de estado
        _auditedProposalsCount = 0;
        delete _proposalsData;

        // Inicio periodo de votacion
        _systemStatus = SystemStatus.VOTING;
    }
    
    function auditProposal(string memory _proposalName) external whenNotPaused() systemStatusIs(SystemStatus.OPEN_PROPOSALS) onlyRole(Role.AUDITOR) {
        require(_proposalDataByName[_proposalName].exists, 'Proposal not found.');
        require(!_proposalDataByName[_proposalName].audited, 'Already audited.');

        _proposalDataByName[_proposalName].audited = true;
        
        _auditedProposalsCount++;
    }

    function authorizeEndVotingPeriod() external whenNotPaused() systemStatusIs(SystemStatus.VOTING) onlyRole(Role.AUDITOR) {
        bool alreadyAuthorized;
        for (uint256 p = 0; p < _votingClosureAuthorizers.length; p++) {
            if (_votingClosureAuthorizers[p] == msg.sender) {
                alreadyAuthorized = true;
            }
        }
        require(!alreadyAuthorized, 'You already authorized to close voting period.');

        _votingClosureAuthorizers.push(address(msg.sender));
    }

    function closeVotingPeriod() external whenNotPaused() systemStatusIs(SystemStatus.VOTING) onlyRole(Role.OWNER) closeVotingAuthorized() {
        uint256 _proposalsBalanceTotal;
        for (uint256 p = 0; p < _proposals.length; p++) {
            _proposalsBalanceTotal += _proposals[p].getBalance();
        }
        require(_proposalsBalanceTotal >= 50, 'Total proposals balance is less than 50 ETH.');

        _systemStatus = SystemStatus.NEUTRAL;

        uint256 _winningBalance;
        uint256 _currentProposalBalance;
        Proposal _currentProposal;
        Proposal _winningProposal;
        for (uint256 p = 0; p < _proposals.length; p++) {
            _currentProposal = _proposals[p];
            _currentProposalBalance = _currentProposal.getBalance();

            // Calcular propuesta ganadora
            if (_currentProposalBalance > _winningBalance) {
                _winningBalance = _currentProposalBalance;
                _winningProposal = _currentProposal;
            } else if (_winningBalance > 0 && _currentProposalBalance == _winningBalance) {
                if (_currentProposal.votesCount() > _winningProposal.votesCount()) {
                    _winningProposal = _currentProposal;
                }
            }
        }

        for (uint256 p = 0; p < _proposals.length; p++) {
            // Comision de 10% del balance del contrato
            _proposals[p].withdraw(address(this), _proposals[p].getBalance()/10);

            // Hacemos selfdestruct de la propuesta perdedora y mandamos el dinero a la ganadora.
            if (address(_proposals[p]) != address(_winningProposal)) {
                _proposals[p].closeAndTransferFunds(address(_winningProposal));
            }
        }
        
        // Transferimos la propiedad del contrato de la propuesta ganadora al maker.
        _winningProposal.transferOwnership(Proposal(_winningProposal).maker());
        winningProposals.push(_winningProposal);

        // Limpio variables de estado
        delete _votingClosureAuthorizers;
        delete _proposals;
    }

    /**
     * @dev Logs senders address and amount (wei sent), then rollback transaction
     */
    receive() external payable {
    }

    fallback() external payable {
    }

    function activateSystem(string memory _action) whenNotPaused() private {
       if (_systemStatus == SystemStatus.INACTIVE && auditorsCount > 1 && _makers.length > 2) {
            _systemStatus = SystemStatus.NEUTRAL;
            emit systemActivated(msg.sender, _action);
        }
    }
}
