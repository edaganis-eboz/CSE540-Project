// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

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
    struct itemStatus {
        // dont know if we should use a enum here
        string status;
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

    address public owner; 
    //Okay so for now we're gonna have a global owner, this is the person who can register actors and probably other things
    // For now just gonna write some function signatures
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can do this");
        _;
    }
    constructor() { // This function requires alot of gas for some reason
        owner = msg.sender;
    }
    function registerActor(address actorAddress, actorRole role) external onlyOwner {
        // Should add an actor to a list
    }
    function createItem(string calldata itemName, string calldata metadata) external returns (uint256) {
        // Create an item object?
    }
    function actorSign(uint256 itemId, string calldata signatureNote) external  {
        // This function will be used for an actor to sign their action
        // May need to be split up into 6 different functions, one for each actor, 
    }
    function getItem(uint256 itemId) external {
        // Returns the item?
    }
    function getSignature(uint256 itemId) external {
        // This should be like a function that lets you view (all?) the signatures for the item
    }

    }