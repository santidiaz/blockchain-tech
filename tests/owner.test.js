const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

// Ejecutar con: [npx hardhat test tests/deploy.test.js --network ganache]
before(async function() {
    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();
});

describe("Add an owner", async function() {
    describe("When sender is an Owner", async function() {
        it("should allow it", async function() {
            expect(await contractInstance.addOwner("0x1928feBA7284b967034D462691df508793DB9edD")).to.be.ok;
        });
    });

    describe("When sender is NOT an Owner", async function() {
        it("should NOT allow it", async function() {
            let expected_result;

            [ownerSigner, notOwnerSigner] = await ethers.getSigners();
            const notOwnerwMsgSender = await contractInstance.connect(notOwnerSigner);

            try {
                await notOwnerwMsgSender.addOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            } catch (error) {
                expected_result = error;
            }

            expect(expected_result).to.be.ok;
            expect(expected_result).to.match(/Ownable: action is not permitted with role/);
        });
    });
});

describe("Open proposal period", async function() {
    describe("When system is INACTIVE", async function() {
        it("should NOT allow it", async function() {
            let expected_result;

            try {
                await contractInstance.openProposalsPeriod();
            } catch (error) {
                expected_result = error;
            }

            expect(expected_result).to.match(/Action unavailable/);
        });
    });

    describe("When system is in NEUTRAL state", async function() {
        it("should allow it", async function() {
            [ownerSigner, makerSigner1, makerSigner2, makerSigner3, auditSigner1, auditSigner2] = await ethers.getSigners();

            // Agregamos minimo 3 Makers
            await contractInstance.addMaker(makerSigner1.address, 'Mkr One', 'Uruguay', '2211');
            await contractInstance.addMaker(makerSigner2.address, 'Mkr Two', 'USA', '3322');
            await contractInstance.addMaker(makerSigner3.address, 'Mkr Three', 'China', '8877');

            // Agregamos minimo 2 Auditors
            await contractInstance.addAuditor(auditSigner1.address);
            await contractInstance.addAuditor(auditSigner2.address);

            expect(await contractInstance.openProposalsPeriod()).to.be.ok;
        });
    });
});
