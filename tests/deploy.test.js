const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

let contractInstance;

// Ejecutar con: [npx hardhat test tests/deploy.test.js]
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

    it("Contract version should be 1.0.0", async function() {
        const contractVersion = await contractInstance.getVersion();
        expect(contractVersion).to.be.equal("1.0.0");
    });

    it("Contract should have one founder with contract creators address", async function() {
        let deployer = await ethers.getSigner();
        const counderAddress = await contractInstance.founder();
        expect(counderAddress).to.be.equal(deployer.address);
    });

    it("Contract should have one owner (the founder)", async function() {
        let deployer = await ethers.getSigner();
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

    describe("When sender is NOT an Owner", async function() {
        it("should NOT allow it", async function() {
            const  provider = getProvider();
    
            let path = "m/44'/60'/0'/0/4"
            const account = ethers.Wallet.fromMnemonic(process.env.MNEMONIC_G, path);
            const wallet = account.connect(provider);
            
            // Borrar
            console.log(wallet.address);
            console.log(ethers.utils.formatEther(await wallet.getBalance()));

            const response = await contractInstance.addOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            await response.wait();

            const isOwner = await contractInstance.isOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            const owners = await contractInstance.getOwners();
            assert(isOwner, 'Not an owner');
            expect(owners.length).to.be.equal(2);

            /*const signerAddress = await ethers.getSigner(newAddr);
            const newContractInstance = await contractInstance.connect(signerAddress);

            console.log(signerAddress.address);

            const response = await newContractInstance.addOwner("0x91209559c4f45B64bBB6a78B9566c81529fDD8C1");
            await response.wait(); // Para que usar este wait si ya esta el <await> arriba?
            */


            /*console.log(algo);*/

            /*const isOwner = await contractInstance.isOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            const owners = await contractInstance.getOwners();
            assert(isOwner, 'Not an owner');
            expect(owners.length).to.be.equal(2);

            await contractInstance.addOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            const isOwner = await contractInstance.isOwner("0x1928feBA7284b967034D462691df508793DB9edD");
            const owners = await contractInstance.getOwners();
            assert(isOwner, 'Not an owner');
            expect(owners.length).to.be.equal(2);

            const owners = await newContractInstance.getOwners();
            console.log(owners.length);*/
            //assert(true, 'test');
        });
    });
});

/*
describe("Acc from mnemonic", async function() {
    it("Load account from mnemonic", async function() {
        const networkInfo = {
            chainid:    5777,
            url:        process.env.GANACHE_URL
        };
        provider = new ethers.providers.JsonRpcProvider(networkInfo);

        let path = "m/44'/60'/0'/0/9"
        const account = ethers.Wallet.fromMnemonic(process.env.MNEMONIC, path);
        const wallet = account.connect(provider);
        console.log(wallet.address);
        console.log(ethers.utils.formatEther(await wallet.getBalance()));

    });
});

*/
getProvider = () => {
    return new ethers.providers.JsonRpcProvider({
        chainid: 5777,
        url: process.env.GANACHE_URL
    });
}
