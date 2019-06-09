pragma solidity ^0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract DressBuyerRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event DressBuyerAdded(address _address);
    event DressBuyerRemoved(address _address);

    // Define a struct 'dress owners' by inheriting from 'Roles' library, struct Role
    Roles.Role private dressBuyers;

    // In the constructor make the address that deploys this contract the 1st grape owner
    constructor() public {
        _addDressBuyer(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyDressBuyer() {
        require(isDressBuyer(msg.sender), "Only dress buyer can call");
        _;
    }

    // Define a function 'isDressBuyer' to check this role
    function isDressBuyer(address _address) public view returns (bool) {
        return dressBuyers.has(_address);
    }

    // Define a function 'addDressBuyer' that adds this role
    function addDressBuyer(address _address) public onlyDressBuyer {
        _addDressBuyer(_address);
    }

    // Define a function 'renounceDressBuyer' to renounce this role
    function renounceDressBuyer() public {
        _removeDressBuyer(msg.sender);
    }

    // Define an internal function '_addDressBuyer' to add this role, called by 'addDressBuyer'
    function _addDressBuyer(address _address) internal {
        dressBuyers.add(_address);
        emit DressBuyerAdded(_address);
    }

    // Define an internal function '_removeConsumer' to remove this role, called by 'renounceDressBuyer'
    function _removeDressBuyer(address _address) internal {
        dressBuyers.remove(_address);
        emit DressBuyerRemoved(_address);
    }
}