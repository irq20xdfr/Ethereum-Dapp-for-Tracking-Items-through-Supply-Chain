pragma solidity ^0.5.0;

import '../dressdesignaccesscontrol/DressBuyerRole.sol';
import '../dressdesignaccesscontrol/DressDesignerRole.sol';
import '../dressdesignaccesscontrol/DressCourierRole.sol';
import '../dressdesigncore/Ownable.sol';

// Define a contract 'Supplychain'
contract SupplyChain is Ownable, DressBuyerRole, DressDesignerRole, DressCourierRole{

  // Define 'owner'
  //address payable owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Dress) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Requested,  // 0
    Reviewed,  // 1
    Confirmed, // 2
    Completed,     // 3
    Paid,       // 4
    Shipped,    // 5
    Delivered,   // 6
    Received   // 7
    }

  State constant defaultState = State.Requested;

  // Define a Designer object to hold info about her/him
  struct Dessigner {
    uint designerID;
  }

  // Define a struct 'Item' with the following fields:
  struct Dress {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Designer, goes on the package, can be verified by the User
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address payable originDesignerID; // Metamask-Ethereum address of the Designer
    string  designerName; // DesignerName
    string  designerInformation;  // Designer Information
    string  designerLocation; // Designer Location
    uint    dressID;  // Dress ID potentially a combination of upc + sku
    string  designNotes; // Dress Design Notes
    uint    designPrice; // Dress Design Price
    State   dressState;  // Dress Design State as represented in the enum above
    address payable userID; // Metamask-Ethereum address of the User
    address courierID; // Metamask-Ethereum address of the User
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Requested(uint upc);
  event Reviewed(uint upc);
  event Confirmed(uint upc);
  event Completed(uint upc);
  event Paid(uint upc);
  event Shipped(uint upc);
  event Delivered(uint upc);
  event Received(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  /*modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }*/

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address, "Bad caller"); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "Payment not enough"); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].designPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].userID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Requested
  modifier requested(uint _upc) {
    require(items[_upc].dressState == State.Requested);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Reviewed
  modifier reviewed(uint _upc) {
    require(items[_upc].dressState == State.Reviewed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Confirmed
  modifier confirmed(uint _upc) {
    require(items[_upc].dressState == State.Confirmed);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Completed
  modifier completed(uint _upc) {
    require(items[_upc].dressState == State.Completed);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Paid
  modifier paid(uint _upc) {
    require(items[_upc].dressState == State.Paid);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].dressState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier delivered(uint _upc) {
    require(items[_upc].dressState == State.Delivered);
    _;
  }

    // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].dressState == State.Received);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    //owner = msg.sender;
    sku = 1;
    upc = 1;
  }
 /*
  // Define a function 'kill' if required
  function kill() public {
   if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }*/

  // Define a function 'requestedItem' that allows a buyer to mark an item 'Requested'
  function requestItem(uint _upc, address payable _originDesignerID, string memory _originDesignerName, string memory _originDesignerInformation, string memory _originDesignerLocation, string memory _designNotes) public 
  {
    // Add the new item as part of Request
    items[_upc] = Dress({
      sku: sku,
      upc: _upc,
      ownerID: _originDesignerID,
      originDesignerID: _originDesignerID,
      designerName: _originDesignerName,
      designerInformation: _originDesignerInformation,
      designerLocation: _originDesignerLocation,
      dressID: sku + _upc,
      designNotes: _designNotes,
      designPrice: 0,
      dressState: State.Requested,
      userID: address(0),
      courierID: address(0)
    });
  
    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Requested(_upc);
  }

  // Define a function 'reviewItem' that allows a designer to mark an item 'Reviewed'
  function reviewItem(uint _upc) public 
  // Call modifier to check if upc has passed previous supply chain stage
  requested(_upc)
  
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].originDesignerID)
  {
    // Update the appropriate fields
    items[_upc].dressState = State.Reviewed;
    
    // Emit the appropriate event
    emit Reviewed(_upc);
  }

  // Define a function 'confirmDesign' that allows a buyer to mark an item 'Confirmed'
  function confirmDesign(uint _upc) onlyDressBuyer public 
  // Call modifier to check if upc has passed previous supply chain stage
  reviewed(_upc)
  // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields
    items[_upc].userID = msg.sender; // When user confirms its ID its set in the field
    items[_upc].dressState = State.Confirmed;
    
    // Emit the appropriate event
    emit Confirmed(_upc);
  }

  // Define a function 'completeDesign' that allows a designer to mark an item 'Completed'
  function completeDesign(uint _upc, uint _price) public 
  // Call modifier to check if upc has passed previous supply chain stage
  confirmed(_upc)
  // Call modifier to verify caller of this function
  verifyCaller(items[_upc].originDesignerID)
  {
    // Update the appropriate fields
    items[_upc].dressState = State.Completed;
    items[_upc].designPrice = _price;
    // Emit the appropriate event
    emit Completed(_upc);
  }

  // Define a function 'buyDress' that allows the dress buyer to mark an item 'Paid'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough,
  // and any excess ether sent is refunded back to the buyer
  function buyDress(uint _upc) onlyDressBuyer public payable 
    // Call modifier to check if upc has passed previous supply chain stage
    completed(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].designPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    {
    // Update the appropriate fields - ownerID, dressState
    items[_upc].ownerID = msg.sender;
    items[_upc].dressState = State.Paid;
    // Transfer money to designer
    items[_upc].originDesignerID.transfer(items[_upc].designPrice);
    // emit the appropriate event
    emit Paid(_upc);
  }


  // Define a function 'shipItem' that allows the courier to mark an item 'Shipped'
  // Use the above modifers to check if the item is paid
  function shipDress(uint _upc) onlyDressCourier public 
  // Call modifier to check if upc has passed previous supply chain stage
  paid(_upc)
  // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields
    items[_upc].dressState = State.Shipped;
    items[_upc].courierID = msg.sender;

    // Emit the appropriate event
    emit Shipped(_upc);
  }


  // Define a function 'deliverDress' that allows the courier to mark an item 'Delivered'
  // Use the above modifiers to check if the item is shipped
  function deliverDress(uint _upc) onlyDressCourier public 
  // Call modifier to check if upc has passed previous supply chain stage
  shipped(_upc)
  // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields - courierID, itemState
    items[_upc].courierID = msg.sender;
    items[_upc].dressState = State.Delivered;
    
    // Emit the appropriate event
    emit Delivered(_upc);
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) onlyDressBuyer public 
  // Call modifier to check if upc has passed previous supply chain stage
  delivered(_upc)
  // Access Control List enforced by calling Smart Contract / DApp
  {
    // Update the appropriate fields - ownerID, itemState
    items[_upc].ownerID = msg.sender;
    items[_upc].dressState = State.Received;
    
    // Emit the appropriate event
    emit Received(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originDesignerID,
  string memory designerName,
  string memory designerInformation,
  string memory designerLocation,
  uint dressID
  ) 
  {
  // Assign values to the 8 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    ownerID = items[_upc].ownerID;
    originDesignerID = items[_upc].originDesignerID;
    designerName = items[_upc].designerName;
    designerInformation = items[_upc].designerInformation;
    designerLocation = items[_upc].designerLocation;
    dressID = items[_upc].dressID;
    
  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originDesignerID,
  designerName,
  designerInformation,
  designerLocation,
  dressID
  );
  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  string memory designNotes,
  uint    designPrice,
  uint    dressState,
  address userID,
  address courierID
  )
  {
    // Assign values to the 9 parameters
    itemSKU = items[_upc].sku;
    itemUPC = items[_upc].upc;
    designNotes = items[_upc].designNotes;
    designPrice = items[_upc].designPrice;
    dressState = uint(items[_upc].dressState);
    userID = items[_upc].userID;
    courierID = items[_upc].courierID;
    
  return
  (
  itemSKU,
  itemUPC,
  designNotes,
  designPrice,
  dressState,
  userID,
  courierID
  );
  }
}
