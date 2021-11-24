const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;
let ownerSigner, makerSigner1, makerSigner2, makerSigner3, auditSigner1, auditSigner2;

// Ejecutar con: [npx hardhat test tests/deploy.test.js --network ganache]
before(async function() {
    [ownerSigner, makerSigner1, makerSigner2, makerSigner3, auditSigner1, auditSigner2] = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();

    // Agregamos minimo 3 Makers
    await contractInstance.addMaker(makerSigner1.address, 'Mkr One', 'Uruguay', '2211');
    await contractInstance.addMaker(makerSigner2.address, 'Mkr Two', 'USA', '3322');
    await contractInstance.addMaker(makerSigner3.address, 'Mkr Three', 'China', '8877');

    // Agregamos minimo 2 Auditors
    await contractInstance.addAuditor(auditSigner1.address);
    await contractInstance.addAuditor(auditSigner2.address);

    await contractInstance.openProposalsPeriod();
});

describe("Add a proposal", async function() {
    describe("When sender is NOT a Maker", async function() {
        it("should NOT allow it", async function() {
            let expected_result;

            try {
                await contractInstance.addProposal("PropName", "PropDesc", 5);
            } catch (error) {
                expected_result = error;
            }

            expect(expected_result).to.be.ok;
            expect(expected_result).to.match(/Ownable: action is not permitted with role/);
        });
    });

    describe("When sender is a Maker", async function() {
        let makerMsgSender;

        before(async function() {
            makerMsgSender = await contractInstance.connect(makerSigner1);
        });

        describe("And proposal does NOT exists", async function() {
            it("should allow it", async function() {
                expect(await makerMsgSender.addProposal("PropName", "PropDesc", 5)).to.be.ok;
            });
        });

        describe("But proposal already exists", async function() {
            it("should NOT allow it", async function() {
                let expected_result;

                try {
                    await makerMsgSender.addProposal("PropName", "SeconDesc", 15);
                } catch (error) {
                    expected_result = error;
                }

                expect(expected_result).to.be.ok;
                expect(expected_result).to.match(/Proposal already exists/);
            });
        });
    });
});
