// This script should be used to deploy our countract
// Currently very basic, uses hardhat for local deployment
import { network } from "hardhat";
const { ethers } = await network.connect({
  network: "hardhatOp",
  chainType: "op",
});

async function main() {
  const MyContract = await ethers.getContractFactory("contract");
  const contract = await MyContract.deploy();

  await contract.waitForDeployment();
  console.log("Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});