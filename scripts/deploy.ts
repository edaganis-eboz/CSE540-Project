// This script should be used to deploy our countract
// Currently very basic, uses hardhat for local deployment
import hre from "hardhat" // so we don't rack up our credit cards

async function main() {
    const contract = await hre.ethers.deployContract("contract");
    await contract.waitForDeployment();
    const address = await contract.getAddress()
}