import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { configVariable, defineConfig, task } from "hardhat/config";
import fs from "node:fs"

// ADDING FUNCTIONS FOR """""CLI"""""

function getAddress(): string {
  const read_addr =  fs.readFileSync("contract_addr.log", "utf8").trim();
  // console.log("Addr is:", read_addr);
  return read_addr;
}

const ROLE_NAMES: Record<number, string> = {
  0: "None",
  1: "Supplier",
  2: "Manufacturer",
  3: "Distributor",
  4: "Retailer",
  5: "Regulator",
  6: "Consumer",
};

const STATUS_NAMES: Record<number, string> = {
  0: "None",
  1: "Created",
  2: "AtSupplier",
  3: "AtManufacturer",
  4: "AtDistributor",
  5: "AtRetailer",
  6: "AtRegulator",
  7: "AtConsumer",
  8: "Retired",
  9: "OnRoute"
};


const registerActor = task("register-actor", "Register a supply chain actor")
  .addPositionalArgument({
    name: "actor",
    description: "Actor wallet address",
  })
  .addPositionalArgument({
    name: "role",
    description: "Role number",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();

    const [owner] = await ethers.getSigners();

    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const role = Number(args.role);

    const tx = await contract
      .connect(owner)
      .registerActor(args.actor, role);

    await tx.wait();

    console.log(`Registered ${args.actor} as ${ROLE_NAMES[role]}`);
  })
  .build();

const createItem = task("create-item", "Create a new supply chain item")
  .addPositionalArgument({
    name: "name",
    description: "Item name",
  })
  .addPositionalArgument({
    name: "meta",
    description: "Metadata string",
    defaultValue: "",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();

    const [, supplier] = await ethers.getSigners();
    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const itemID = await contract
    .connect(supplier)
    .createItem.staticCall(args.name, args.meta);

    const tx = await contract
      .connect(supplier)
      .createItem(args.name, args.meta);

    await tx.wait();

    console.log(`Created item: ${args.name} with ID: ${itemID}`);
  })
  .build();

const getItem = task("get-item", "Get an item by ID")
  .addPositionalArgument({
    name: "id",
    description: "Item ID",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();

    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const item = await contract.getItem(Number(args.id));

    console.log("Item:");
    console.log("  id:", item[0].toString());
    console.log("  name:", item[1]);
    console.log("  metadata:", item[2]);
    console.log("  creator:", item[3]);
    console.log("  status:", STATUS_NAMES[Number(item[4])]);
  })
  .build();

const getItemSignatures = task("get-item-signatures", "Gets all the signatures of an item")
  .addPositionalArgument({
    name: "id",
    description: "Item ID",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();

    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const sigs = await contract.getSignatures(Number(args.id));

     if (sigs.length === 0) {
      console.log(`No signatures for item ${args.id}`);
      return;
    }

    console.log(`Signatures for item ${args.id}:`);

    sigs.forEach((sig: any, i: number) => {
      const signer = sig.signer ?? sig[0];
      const role = sig.role ?? sig[1];
      const timestamp = sig.timestamp ?? sig[2];
      const note = sig.note ?? sig[3];

      console.log(`--- Signature ${i} ---`);
      console.log("  signer:", signer);
      console.log("  role:", ROLE_NAMES[Number(role)]);
      console.log("  timestamp:", timestamp.toString());
      console.log("  note:", note);
    });
  })
  .build();

const actorReceiveSign = task("receive-sign", "Sign an item upon receiving")
  .addPositionalArgument({
    name: "id",
    description: "Item ID",
  })
  .addPositionalArgument({
    name: "address",
    description: "Signer wallet address",
  })
  .addPositionalArgument({
    name: "note",
    description: "Signing note",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();
    const signers = await ethers.getSigners();

    // find signer by address
    const signer = signers.find(
      (s) => s.address.toLowerCase() === args.address.toLowerCase()
    );

    if (!signer) {
      throw new Error("Address is not one of the available signers");
    }

    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const tx = await contract
      .connect(signer)
      .actorReceiveSign(Number(args.id), args.note);

    await tx.wait();

    console.log(
      `Signer received/signed item ${args.id}: ${args.note}`
    );
  })
  .build();


const actorSendSign = task("send-sign", "Sign item when sending")
  .addPositionalArgument({
    name: "id",
    description: "Item ID",
  })
    .addPositionalArgument({
    name: "address",
    description: "Signer wallet address",
  })
  .addPositionalArgument({
    name: "note",
    description: "Signing note",
  })
  .setInlineAction(async (args, hre) => {
    const { ethers } = await hre.network.connect();
    const signers = await ethers.getSigners();

    // find signer by address
    const signer = signers.find(
      (s) => s.address.toLowerCase() === args.address.toLowerCase()
    );

    if (!signer) {
      throw new Error("Address is not one of the available signers");
    }

    const contract = await ethers.getContractAt(
      "SupplyChainProvenance",
      getAddress()
    );

    const tx = await contract
      .connect(signer)
      .actorSendSign(Number(args.id), args.note);

    await tx.wait();

    console.log(
      `Signer sent/signed item ${args.id}: ${args.note}`
    );
  })
  .build();


// actual config stuff

export default defineConfig({
  plugins: [hardhatToolboxMochaEthersPlugin],
  tasks: [registerActor, createItem, getItem, actorReceiveSign, actorSendSign, getItemSignatures],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
  //   hardhatMainnet: { 
  //   type: "edr-simulated", 
  //   chainType: "l1", 
  // },
  //   hardhatOp: { 
  //   type: "edr-simulated", 
  //   chainType: "op", 
  // },
    localhost: {
    type: "http",
    chainType: "l1",
    url: "http://127.0.0.1:8545",
  },
  //   sepolia: { 
  //   type: "http", 
  //   chainType: "l1", 
  //   url: configVariable("SEPOLIA_RPC_URL"), 
  //   accounts: [configVariable("SEPOLIA_PRIVATE_KEY")], 
  // },
  },
});
