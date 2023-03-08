// scripts/upgrade_box.js
const { ethers, upgrades } = require("hardhat");
const { contractAddress } = require("../secret.json");
/// the secrect json should not be uploaded on github
/// normally i would add it to .gitignore

async function main() {
	// upgrading the contract. This should be done in a different script folder
	const factoryV2 = await ethers.getContractFactory("CrowdFundingV2");
	console.log("Upgrading ...");

	await upgrades.upgradeProxy(`${contractAddress}`, factoryV2);
	console.log("Contract upgraded");
}

main();
