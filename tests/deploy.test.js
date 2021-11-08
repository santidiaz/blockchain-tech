const { expect } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

before(async function() {
    console.log("-- Deploy started");

    const deployer = await ethers.getSigner(); // Obtiene la primera cuenta en mi nodo local
    console.log("-- Deployer account address: ", deployer.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));

    const contractFactory = await ethers.getContractFactory("MyDeployContract");
    const contractInstance = await contractFactory.deploy();
    console.log("-- Contract deployed to address: ", contractInstance.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));
    console.log("-- Deploy finished");
});

describe("Deploy test", async function() {
    it("Contract should be deployed successfully", async function() {
        expect(contractInstance).to.be.ok;
    });

    it("Version of the contract should be 1.0.0", async function() {
        const contractVersion = await contractInstance.getVersion();
        expect(contractVersion).to.be.equal("1.0.0");
    });
});

describe("Set value test", async function() {
    it("Set myVariable to 20", async function() {
        const tsx = await contractInstance.setMyVariable(20);
        await tsx.wait();
        const contractMyVariable = parseInt(await contractInstance.myVariable());

        expect(contractMyVariable).to.be.equal(20);
    });
});