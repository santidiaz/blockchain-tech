const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

// Ejecutar con: [npx hardhat test tests/deploy.test.js --network ganache]
// Ejecutar toda la carpeta: [npx hardhat test tests/* --network ganache]
before(async function() {
    console.log("-- Deploy started");

    let deployer = await ethers.getSigner(); // Obtiene la primera cuenta en mi nodo local
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

    it("Contract should have founder as owner", async function() {
        let deployer = await ethers.getSigner();
        const owner = await contractInstance.getOwner();

        expect(owner).to.be.equal(deployer.address);
    });
});
