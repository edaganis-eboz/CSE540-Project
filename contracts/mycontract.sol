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
        created,
        atSupplier,
        atManufacturer,
        atDistributor,
        atRetailer,
        atRegulator,
        atConsumer,
        retired, // after consumer
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
    mapping(uint256 => signature[]) private itemSignatures;
    uint16 nextItemIndex = 1; //THE ITEM ID WILL BE THE ITEMS INDEX ON THIS LIST
    address public owner; 
    // Okay so for now we're gonna have a global owner, this is the person who can register actors and probably other things
    
    // For now just gonna write some function signatures
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }

    modifier itemExists(uint256 itemId) {
        require(itemList[itemId].exists, "Item does not exist");
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
            status: itemStatus.onRoute, // Doing this just for testing sake
            exists: true
        });
        nextItemIndex++; 
        // emit itemCreated event
        emit itemCreated(itemId, itemName, msg.sender);
        return itemId;
    }

    
    function sign(uint256 itemId, string calldata note) internal {
        // add signature to a list of signatures for item
        itemSignatures[itemId].push(
            signature({
                signer: msg.sender,
                role: actorList[msg.sender].role,
                timestamp: block.timestamp,
                note: note
            })
        );
        // emit event
        emit itemSigned(
            itemId,
            msg.sender,
            actorList[msg.sender].role,
            itemList[itemId].status,
            note
        );
    }

    function actorReceiveSign(uint256 itemId, string calldata signatureNote) external itemExists(itemId)  {
        // This function will be used for an actor to sign when they receive an item
        // Thus the itemstatus should be "onRoute" and then changed to "atWhoever"
        require(actorList[msg.sender].exists, "Not a registered actor");

        actorRole role = actorList[msg.sender].role;
        item storage itemToSign = itemList[itemId];
        require(itemToSign.status == itemStatus.onRoute, "Invalid item status");
        // TODO item starts as created to need to make a branch, or just change it to on route
        if (role == actorRole.Supplier) {
            itemToSign.status = itemStatus.atSupplier;
        }

        else if (role == actorRole.Manufacturer) {
            itemToSign.status = itemStatus.atManufacturer;
        }

        else if (role == actorRole.Distributor) {
            itemToSign.status = itemStatus.atDistributor;
        }

        else if (role == actorRole.Retailer) {
            itemToSign.status = itemStatus.atRetailer;
        }

        else if (role == actorRole.Regulator) {
            itemToSign.status = itemStatus.atRegulator;
        }

        else if (role == actorRole.Consumer) {
            itemToSign.status = itemStatus.atConsumer;
        }

        else {
            revert("Something went wrong");
        }
        sign(itemId, signatureNote);

    }
    function actorSendSign(uint256 itemId, string calldata signatureNote) external itemExists(itemId) {
        // This function will be used for an actor to sign when they send out an item
        // Thus itemstatus should be "atWhoever" and then changed to "onRoute"
        require(actorList[msg.sender].exists, "Not a registered actor");

        actorRole role = actorList[msg.sender].role;
        item storage itemToSign = itemList[itemId];
        require(itemToSign.status != itemStatus.onRoute, "Invalid item status");
        // TODO item starts as created to need to make a branch, or just change it to on route
        if (role == actorRole.Supplier) {
            require(itemToSign.status == itemStatus.atSupplier, "Invalid item status");
            itemToSign.status = itemStatus.onRoute;
        }

        else if (role == actorRole.Manufacturer) {
            require(itemToSign.status == itemStatus.atManufacturer, "Invalid item status");
            itemToSign.status = itemStatus.onRoute;
        }

        else if (role == actorRole.Distributor) {
            require(itemToSign.status == itemStatus.atDistributor, "Invalid item status");
            itemToSign.status = itemStatus.onRoute;
        }

        else if (role == actorRole.Retailer) {
            require(itemToSign.status == itemStatus.atRetailer, "Invalid item status");
            itemToSign.status = itemStatus.onRoute;
        }

        else if (role == actorRole.Regulator) {
            require(itemToSign.status == itemStatus.atRegulator, "Invalid item status");
            itemToSign.status = itemStatus.onRoute;
        }

        else if (role == actorRole.Consumer) {
            require(itemToSign.status == itemStatus.atConsumer, "Invalid item status");
            itemToSign.status = itemStatus.retired;
        }

        else {
            revert("Something went wrong");
        }
        sign(itemId, signatureNote);

    }
    function getItem(uint256 itemId) external view returns (
        uint256 id,
        string memory itemName,
        string memory itemMetadata,
        address itemCreator,
        itemStatus status
    ) // return struct data as a tuple for reasons, trust me bro
    {
        item memory returnItem = itemList[itemId];
        return (returnItem.itemId, returnItem.itemName, returnItem.metadata, returnItem.creator, returnItem.status);
    }
    function getSignature(uint256 itemId, uint256 signatureIndex) external view returns (
        address signerAddress,
        actorRole signerRole,
        uint256 signatureTimestamp,
        string memory signatureNote
    ) {
        //TODO right now i dont know how to do this better, I would rather it return a list of all the signatures
        require(signatureIndex < itemSignatures[itemId].length, "Index out of bounds");

        signature memory sig = itemSignatures[itemId][signatureIndex];
        return (sig.signer, sig.role, sig.timestamp, sig.note);
    }

    }