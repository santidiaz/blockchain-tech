// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Maker.sol";

contract Proposal {
    // State variables
    string public name;
    string public description;
    uint256 private _min_amount_required = 5; // Q: Tiene sentido setear esto privado y agregar un metodo para que sea solo lectura?
    Maker private _maker;

    // - Que la suma de los balances de los contratos de las propuestas hayan alcanzado un mínimo de 50 ethers
    // - Que el cierre sea autorizado por al menos 2 auditors
    uint256 private _votes_count;
    uint256[] public authors_autoriza;
    
    // Mappings

    // Enums

    // Structs

    // Address
    
    // Events

    // Modifiers

    // Constructor
    constructor() {}
    
    // Functions
    receive() external payable {
        // revert(); // rollback transaction
        // emit myEvent(); // Ejemplo logear algo.
    }
}
