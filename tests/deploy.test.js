const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;
let deployer;

// Ejecutar con: [npx hardhat test tests/deploy.test.js]
before(async function() {
    console.log("-- Deploy started");

    deployer = await ethers.getSigner(); // Obtiene la primera cuenta en mi nodo local
    console.log("-- Deployer account address: ", deployer.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));

    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();
    console.log("-- Contract deployed to address: ", contractInstance.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));
    console.log("-- Deploy finished");
});

describe("Deploy test", async function() {
    it("Contract should be deployed successfully", async function() {
        expect(await contractInstance).to.be.ok;
    });

    it("Contract version should be 1.0.0", async function() {
        const contractVersion = await contractInstance.getVersion();
        expect(contractVersion).to.be.equal("1.0.0");
    });

    it("Contract should have one founder with contract creators address", async function() {
        const counderAddress = await contractInstance.founder();
        expect(counderAddress).to.be.equal(deployer.address);
    });

    it("Contract should have one owner (the founder)", async function() {
        const owners = await contractInstance.getOwners();

        expect(owners.length).to.be.equal(1);
        expect(owners[0]).to.be.equal(deployer.address);
    });
});


describe("Add an owner", async function() {
    describe("When sender is an Owner", async function() {
        it("should allow it", async function() {
            await contractInstance.addOwner("0x1928feBA7284b967034D462691df508793DB9edD");

            const isOwner = await contractInstance.isOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            const owners = await contractInstance.getOwners();
            assert(isOwner, 'Not an owner');
            expect(owners.length).to.be.equal(2);
        });
    });

    /*describe("When sender is NOT an Owner", async function() {
        it("should NOT allow it", async function() {
            // Como pruebo los requires?
            expect(await contractInstance).to.be.ok;
        });
    });*/
});
