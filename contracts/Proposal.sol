// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Ownable/Ownable.sol";
import "./Pausable/Pausable.sol";

contract Proposal is Ownable, Pausable {
    // State variables
    string public name;
    string public description;
    uint256 public votesCount;
    uint256 private _minAmountRequired = 5; // ethers

    // Structs
    struct ProposalData {
        string name;
        string description;
        uint256 minAmountRequired;
        uint256 balance; // ethers
        address maker;
        bool audited;
        bool exists;
    }

    // Address
    address public maker;
    address public owner;
    
    // Events
    event makerSet(address indexed addedBy, address indexed newMaker);
    event ownerSet(address indexed addedBy, address indexed newOwner);
    event transferRolledBack(address indexed _from, uint _amount);

    // Modifiers
    modifier balanceAvailable(uint256 _amount) {
        require(address(this).balance > _amount, "Insufficient balance.");
        _;
    }

    // Constructor
    constructor(string memory _name, string memory _description, address _maker, uint256 _minAmount) payable {
        name = _name;
        description = _description;
        maker = _maker;
        _minAmountRequired = _minAmount;
        owner = address(msg.sender);

        emit makerSet(address(0), maker);
        emit ownerSet(address(0), owner);
    }
    
    // Functions
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }

    function vote() external payable {
        require(msg.value >= _minAmountRequired, string(abi.encodePacked("Minimum required to vote is", _minAmountRequired)));
        votesCount++;
    }

    function withdraw(address _remitent, uint256 _amount) external onlyOwner() whenNotPaused() balanceAvailable(_amount) {
        payable(_remitent).transfer(_amount);
    }

    function closeAndTransferFunds(address _owner) external payable onlyOwner() whenNotPaused() {
        selfdestruct(payable(address(_owner)));
    }

    /**
     * @dev Logs senders address and amount (wei sent), then rollback transaction
     */
    receive() external payable {
        emit transferRolledBack(msg.sender, msg.value);
        revert();
    }

    fallback() external payable {}
}
