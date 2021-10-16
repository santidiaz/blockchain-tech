//SPDX-License-Identifier:MIT
pragma solidity 0.8.4;

import "./Proposal.sol";

contract SmartInvestment {
    Proposal[] private _proposals;

    constructor() {}

    function getVersion() external pure returns(string memory) {
        return "1.0.0";
    }

    // <view> porque va a leer de la blockchain.
    // No <external> porque puede ser leeido desde adentro del contrato tambien.
    function getProposalsCount() public view returns(uint count) {
        return _proposals.length;
    }

    // function createProposal() 
}