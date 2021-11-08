const { ethers } = require("hardhat");

// Ejecutar deploy con: [npx hardhat run scripts/deploy_01.js --network rinkeby]
async function main() {
    console.log("=> Deploy started...");

    const deployer = await ethers.getSigner();
    console.log("=> Deployer account address: ", deployer.address);
    console.log("=> Address balance before deploy: ", ethers.utils.formatEther(await deployer.getBalance()));

    const contractFactory = await ethers.getContractFactory("SmartInvestment");
    const contractInstance = await contractFactory.deploy();
    console.log("=> Contract deployed to address: ", contractInstance.address);
    console.log("-- Address balance after deploy: ", ethers.utils.formatEther(await deployer.getBalance()));
    console.log("-- Deploy finished");
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
})
