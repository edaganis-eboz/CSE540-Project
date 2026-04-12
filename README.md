# Project Description


## Description

This project implements a blockchain-based supply chain provenance system designed to improve transparency, traceability, and trust across multiple stakeholders. Traditional supply chains rely on centralized and fragmented systems, making it difficult to track products and verify authenticity.

Our system uses blockchain technology to create a shared, immutable ledger where product lifecycle events are recorded securely. This ensures that all stakeholders have access to a consistent and tamper-proof history of a product.

## Roles in Supply Chain
- Supplier -> Registers products
- Manufacturer -> Processes and updates products
- Distributor -> Handles shipment and custody transfer
- Retailer -> Receives and delivers products
- Regulator -> Verifies and validates product records
- Consumer -> Views product provenance and authenticity

## Dependencies

Currently the dependencies are all the default dependencies that remix does. This includes Chai and Mocha, and whatever dependencies that hardhat has.

## How to use or deploy

Currently there is no way to deploy. There will be a typescript file in scripts/ that will be used to deploy. 



## Project Structure
* contracts/ → Solidity smart contracts
* scripts/ → Deployment scripts
* test/ → Test files
* README.md → Project documentation

## Usage

Users can interact with the system by:

* Registering products
* Updating product status
* Transferring ownership between stakeholders
* Viewing product history on the blockchain

To run:

npx hardhat compile

in a different terminal run npx hardhat node

npx hardhat run scripts/deploy.ts --network localhost


## Future Improvements

* Integration with IoT devices for real-time tracking
* Enhanced access control mechanisms
* Frontend web interface for better usability
* Improved scalability and gas optimization

## Team Members

* Karthik Venkata Sai Reddy Kunduru
* Shiva Reddy Marri
* Kamal Teja Annamdasu
* Pardha Praneeth Pudi
* Erin Ozcan

## Course

CSE 540: Engineering Blockchain Applications
Arizona State University
