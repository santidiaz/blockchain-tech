// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Pausable {
    // State variables
    bool private _paused;
    
    // Events
    event Paused(address account);
    event Unpaused(address account);

    // Modifiers
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    // Constructor
    constructor() {
         _paused = false;
    }
    
    // Functions
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }


    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

}
