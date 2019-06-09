pragma solidity ^0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract DressDesignerRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event DressDesignerAdded(address _address);
    event DressDesignerRemoved(address _address);

    // Define a struct 'dress owners' by inheriting from 'Roles' library, struct Role
    Roles.Role private dressDesigners;

    // In the constructor make the address that deploys this contract the 1st grape owner
    constructor() public {
        _addDressDesigner(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyDressDesigner() {
        require(isDressDesigner(msg.sender), "Only dress Designer can call");
        _;
    }

    // Define a function 'isDressDesigner' to check this role
    function isDressDesigner(address _address) public view returns (bool) {
        return dressDesigners.has(_address);
    }

    // Define a function 'addDressDesigner' that adds this role
    function addDressDesigner(address _address) public onlyDressDesigner {
        _addDressDesigner(_address);
    }

    // Define a function 'renounceDressDesigner' to renounce this role
    function renounceDressDesigner() public {
        _removeDressDesigner(msg.sender);
    }

    // Define an internal function '_addDressDesigner' to add this role, called by 'addDressDesigner'
    function _addDressDesigner(address _address) internal {
        dressDesigners.add(_address);
        emit DressDesignerAdded(_address);
    }

    // Define an internal function '_removeConsumer' to remove this role, called by 'renounceDressDesigner'
    function _removeDressDesigner(address _address) internal {
        dressDesigners.remove(_address);
        emit DressDesignerRemoved(_address);
    }
}