pragma solidity ^0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract DressCourierRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event DressCourierAdded(address _address);
    event DressCourierRemoved(address _address);

    // Define a struct 'dress owners' by inheriting from 'Roles' library, struct Role
    Roles.Role private dressCouriers;

    // In the constructor make the address that deploys this contract the 1st grape owner
    constructor() public {
        _addDressCourier(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyDressCourier() {
        require(isDressCourier(msg.sender), "Only dress Courier can call");
        _;
    }

    // Define a function 'isDressCourier' to check this role
    function isDressCourier(address _address) public view returns (bool) {
        return dressCouriers.has(_address);
    }

    // Define a function 'addDressCourier' that adds this role
    function addDressCourier(address _address) public onlyDressCourier {
        _addDressCourier(_address);
    }

    // Define a function 'renounceDressCourier' to renounce this role
    function renounceDressCourier() public {
        _removeDressCourier(msg.sender);
    }

    // Define an internal function '_addDressCourier' to add this role, called by 'addDressCourier'
    function _addDressCourier(address _address) internal {
        dressCouriers.add(_address);
        emit DressCourierAdded(_address);
    }

    // Define an internal function '_removeConsumer' to remove this role, called by 'renounceDressCourier'
    function _removeDressCourier(address _address) internal {
        dressCouriers.remove(_address);
        emit DressCourierRemoved(_address);
    }
}