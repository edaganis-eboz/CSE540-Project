// This script should be used to deploy our countract
// Currently very basic, uses hardhat for local deployment
const hre = require("hardhat");

async function main() {
  const MyContract = await hre.ethers.getContractFactory("YourContractName");
  const contract = await MyContract.deploy(); // add constructor args here if needed

  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});