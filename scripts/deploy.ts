// This script should be used to deploy our countract
// Currently very basic, uses hardhat for local deployment
import { network } from "hardhat";
import * as fs from "fs";

const { ethers } = await network.connect({
  network: "localhost",
  chainType: "l1",
});

async function main() {
  const MyContract = await ethers.getContractFactory("SupplyChainProvenance");
  const contract = await MyContract.deploy();

  await contract.waitForDeployment();
  const contract_addr = await contract.getAddress()
  console.log("Contract deployed to:", contract_addr );
  fs.writeFileSync("contract_addr.log", contract_addr);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});