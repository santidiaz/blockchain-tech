const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance, makerAccount, proposalAccount, voterAccount, deployer;
let ownerSigner, makerSigner, proposalSigner, voterSigner, auditorSigner;

// Ejecutar con: [npx hardhat test tests/deploy.test.js]
before(async function() {
    console.log("-- Deploy started");

    //let deployer = await ethers.getSigner(); // Obtiene la primera cuenta en mi nodo local
    deployer = await ethers.getSigner();
    console.log("deployer ",deployer.address);
    console.log("-- Deployer account address: ", deployer.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));

    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    contractInstance = await contractFactory.deploy();
    console.log("-- Contract deployed to address: ", contractInstance.address);
    console.log("-- Deploy account balance: ", ethers.utils.formatEther(await deployer.getBalance()));
    console.log("-- Deploy finished");
});


describe("Vote", async function() {
    before(async function() {
        [ownerSigner, makerSigner, proposalSigner, voterSigner, auditorSigner] = await ethers.getSigners();
        makerAccount = makerSigner.address;
        proposalAccount = proposalSigner.address;
        auditorAccount = auditorSigner.address;
        voterAccount = voterSigner.address;
        await contractInstance.addMaker(makerAccount, "maker3", "country", 1234);
        await contractInstance.addMaker(ownerSigner.address, "maker1", "country", 1234);
        await contractInstance.addMaker(proposalSigner.address, "maker2", "country", 1234);
        await contractInstance.addAuditor(auditorAccount);
        await contractInstance.openProposalsPeriod();
        let newMsgSender = await contractInstance.connect(makerSigner);
        await newMsgSender.addProposal("Propuesta", "Descripcion", 6);
        await newMsgSender.addProposal("Propuesta2", "Descripcion", 7);
        let auditor = await contractInstance.connect(auditorSigner);
        await auditor.auditProposal("Propuesta");
        await auditor.auditProposal("Propuesta2");
    });
/*     it("Should not allow to vote if period of voting is not open", async function() {
        const result = contractInstance.connect(voterSigner).vote(proposalAccount, 50);
        await expect(result).to.revertedWith("VM Exception while processing transaction: revert System unavailable.")
    }); */
    it("Should allow to vote", async function() {
        await contractInstance.closeProposalsPeriod();
        const result = await contractInstance.connect(voterSigner).vote("Propuesta", 6);
        expect(result).to.be.true;
    });
});

getProvider = () => {
    return new ethers.providers.JsonRpcProvider({
        chainid: 5777,
        url: process.env.GANACHE_URL
    });
}