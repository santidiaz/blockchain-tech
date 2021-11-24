const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

// Ejecutar con: [npx hardhat test tests/deploy.test.js --network ganache]
before(async function() {
    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();
});

describe("Add a maker", async function() {
    describe("When sender is an Owner", async function() {
        it("should allow it", async function() {
            expect(await contractInstance.addMaker("0x1928feBA7284b967034D462691df508793DB9edD", "maker", "country", 123)).to.be.ok;
        });
    });

    describe("When sender is NOT an Owner", async function() {
        it("should NOT allow it", async function() {
            let expected_result;

            [ownerSigner, notOwnerSigner] = await ethers.getSigners();
            const notOwnerwMsgSender = await contractInstance.connect(notOwnerSigner);

            try {
                await notOwnerwMsgSender.addMaker("0x1928feBA7284b967034D462691df508793DB9edD", "maker", "country", 123);
            } catch (error) {
                expected_result = error;
            }

            expect(expected_result).to.be.ok;
            expect(expected_result).to.match(/Ownable: action is not permitted with role/);
        });
    });
});
