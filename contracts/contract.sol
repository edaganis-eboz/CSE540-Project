// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
// please use camelCase
// TODO:
// add require checks to create functions

contract SupplyChainProvenance {
    // The data types we'll probably need
    enum actorRole {
        None,
        Supplier,
        Manufacturer,
        Distributor,
        Retailer,
        Regulator,
        Consumer
    }
    enum itemStatus {
        // dont know if we should use a enum here
        created,
        atSupplier,
        atManufacturer,
        atDistributor,
        atRetailer,
        atRegulator,
        atConsumer,
        retired,
        onRoute
    }
    struct actor {
        actorRole role;
        address actorAddress;
        bool exists;
    }
    struct signature {
        address signer;
        actorRole role;
        uint256 timestamp;
        string note;
    }
    struct item {
        uint256 itemId;
        string itemName;
        string metadata;
        address creator;
        itemStatus status;
        bool exists;
    }
    mapping(uint256 => item) public itemList;
    mapping(address => actor) public actorList;
    uint16 nextItemIndex = 1; //THE ITEM ID WILL BE THE ITEMS INDEX ON THIS LIST
    address public owner; 
    // Okay so for now we're gonna have a global owner, this is the person who can register actors and probably other things
    
    // For now just gonna write some function signatures
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }
    constructor() { // This function requires alot of gas for some reason
        owner = msg.sender;
    }

    // All the events we'll need
    event actorRegistered(address indexed actorAddr, actorRole role);
    event itemCreated(uint256 indexed itemId, string itemName, address indexed creatorAddr);
    // When an item gets signed, assume its in a new status
    event itemSigned(
        uint256 indexed itemId,
        address indexed signerAddr,
        actorRole role,
        itemStatus updatedStatus,
        string note
    );

    function registerActor(address actorAddr, actorRole role) external onlyOwner {
        // Should add an actor to a list
        actorList[actorAddr] = actor({
            role: role,
            actorAddress: actorAddr,
            exists: true
        });
        // emit actorRegistered event
        emit actorRegistered(actorAddr, role);
    }
    function createItem(string calldata itemName, string calldata metadata) external returns (uint256) {
        // Create an item object
        // add it to the itemList
        // increment nextItemIndex
        uint256 itemId = nextItemIndex;
        itemList[itemId] = item({
            itemId: itemId,
            itemName: itemName,
            metadata: metadata,
            creator: msg.sender,
            status: itemStatus.created,
            exists: true
        });
        nextItemIndex++; 
        // emit itemCreated event
        emit itemCreated(itemId, itemName, msg.sender);
        return itemId;
    }
    function actorReceiveSign(uint256 itemId, string calldata signatureNote) external  {
        // This function will be used for an actor to sign when they receive an item
        // Thus the itemstatus should be "onRoute" and then changed to "atWhoever"
        
    }
    function actorSendSign(uint256 itemId, string calldata signatureNote) external  {
        // This function will be used for an actor to sign when they send out an item
        // Thus itemstatus should be "atWhoever" and then changed to "onRoute"
    }
    function getItem(uint256 itemId) external view returns (
        uint256 id,
        string memory itemName,
        string memory itemMetadata,
        address itemCreator,
        itemStatus status
    ) // return struct data as a tuple for reasons, trust me bro
    {
        // Find the item on the mapping using itemID as index
        // Returns the item data as a tuple
    }
    function getSignature(uint256 itemId) external view returns (
        address signerAddress,
        actorRole signerRole,
        uint256 signatureTimestamp,
        string memory signatureNote
    ) {
        // This should be like a function that lets you view (all?) the signatures for the item
        // Should items have a list for signatures?
    }

    }