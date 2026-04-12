import { expect } from "chai";
import { network } from "hardhat";

describe("SupplyChainProvenance", function () {
  async function deployFixture() {
    const { ethers } = await network.connect();
    const [owner, supplier, manufacturer, distributor, retailer, consumer, other] =
      await ethers.getSigners();

    const contract = await ethers.deployContract("SupplyChainProvenance");
    await contract.waitForDeployment();

    return {
      ethers,
      contract,
      owner,
      supplier,
      manufacturer,
      distributor,
      retailer,
      consumer,
      other,
    };
  }

  describe("registerActor", function () {
    it("registers an actor with the correct role", async function () {
      const { contract, supplier } = await deployFixture();

      const supplierAddress = await supplier.getAddress();
      await (await contract.registerActor(supplierAddress, 1)).wait();

      const actor = await contract.actorList(supplierAddress);
      expect(actor.exists).to.equal(true);
      expect(actor.role).to.equal(1);
    });

    it("reverts if a non-owner tries to register an actor", async function () {
      const { contract, supplier, manufacturer } = await deployFixture();

      await expect(
        contract.connect(supplier).registerActor(await manufacturer.getAddress(), 2)
      ).to.be.revertedWith("Only the owner can do this");
    });
  });

  describe("createItem", function () {
    it("creates an item", async function (){
      const { contract, supplier } = await deployFixture();
      const supplierAddress = await supplier.getAddress();
      await (await contract.registerActor(supplierAddress, 1)).wait();

      await (await contract.connect(supplier).createItem("TestItemName", "TestItemMetaData")).wait();

      const item = await contract.itemList(1); // 1 is the item ID
      expect(item.exists).to.equal(true);
      expect(item.itemId).to.equal(1);
      expect(item.itemName).to.equal("TestItemName");
      expect(item.metadata).to.equal("TestItemMetaData");
      expect(item.creator).to.equal(supplierAddress);
      expect(item.status).to.equal(8);
    });
  });
    describe("signItem", function () {
    it("signs an item", async function (){
      const { contract, supplier } = await deployFixture();
      const supplierAddress = await supplier.getAddress();
      await (await contract.registerActor(supplierAddress, 1)).wait();

      await (await contract.connect(supplier).createItem("TestItemName", "TestItemMetaData")).wait();

      // item ID is 1
      await (await contract.connect(supplier).actorReceiveSign(1, "TestSignatureNote")).wait()
      const item = await contract.itemList(1);
      expect(item.status).to.equal(1); //atSupplier status

    });

    it("reverts if signed at an improper status", async function () {
      const { contract, supplier } = await deployFixture();

      const supplierAddress = await supplier.getAddress();
      await (await contract.registerActor(supplierAddress, 1)).wait();

      await (await contract.connect(supplier).createItem("TestItemName", "TestItemMetaData")).wait();

      await expect(
        contract.connect(supplier).actorSendSign(1, "TestSignatureNote")
      ).to.be.revertedWith("Invalid item status");
    });
  });

});