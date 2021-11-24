const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

// Ejecutar con: [npx hardhat test tests/deploy.test.js --network ganache]
before(async function() {
    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();
});

describe("Looking into bloom filters", async function() {
    describe("When something...", async function() {
        it("should something...", async function() {
           
        });
    });
});
