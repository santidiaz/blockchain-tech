// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Proposal {
    // State variables
    string public name;
    string public description;
    uint256 private _minAmountRequired = 5; // ethers
    Voter[] private _voters;

    struct Voter {
        address account;
        bool voted;
        uint256 balance; // Cada vez que vota, se suma el monto aca
    }

    // - Que la suma de los balances de los contratos de las propuestas hayan alcanzado un mínimo de 50 ethers
    // - Que el cierre sea autorizado por al menos 2 auditors
    uint256 private _votesCount;
    
    // Mappings
    mapping(address => Voter) public voters;

    // Enums

    // Structs

    // Address
    address public maker;
    address public owner;

    
    // Events
    event makerSet(address indexed addedBy, address indexed newMaker);
    event ownerSet(address indexed addedBy, address indexed newOwner);
    event transferRolledBack(address indexed _from, uint _amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner.");
        _;
    }

    modifier balanceAvailable() {
        require(address(this).balance > 0);
        _;
    }

    // Constructor
    constructor(string memory _name, string memory _description, address _maker, uint256 _minAmount) {
        name = _name;
        description = _description;
        maker = _maker;
        _minAmountRequired = _minAmount;
        owner = address(msg.sender);

        emit makerSet(address(0), maker);
        emit ownerSet(address(0), owner);
    }
    
    // Functions
    function vote() external payable {
        require(msg.value >= _minAmountRequired, string(abi.encodePacked("Minimum required to vote is", msg.value)));

        _votesCount++;
        if (voters[address(msg.sender)].voted) {
            voters[address(msg.sender)].balance += msg.value;
        } else {
            _voters.push(
                Voter(
                    address(msg.sender),
                    true, // voted
                    msg.value // amount voted
                )
            );
        }

        // Require amount > 
        payable(address(this)).transfer(msg.value); // transfer funds to owner acc
    }

    function withdraw(address _remitent) external onlyOwner() balanceAvailable() {
        payable(_remitent).transfer(address(this).balance);
    }

    function transferOwnership() external onlyOwner() {
        owner = maker;

        emit ownerSet(msg.sender, owner);
    }

    /**
     * @dev Logs senders address and amount (wei sent), then rollback transaction
     */
    receive() external payable {
        emit transferRolledBack(msg.sender, msg.value);
        revert();
    }
}
