// scripts/deploy.js
const { ethers, upgrades } = require("hardhat");

async function main() {
	//deploy the custom token
	const tokenFactory = await ethers.getContractFactory("BenBurgerToken");
	console.log("Deploying Token...");
	const tokenContract = await tokenFactory.deploy();
	console.log("Token deployed to:", tokenContract.address);

	const crowdFundingfactory = await ethers.getContractFactory("CrowdFunding");
	const goal = 10000;
	const deadline = 1000000;
	const minimumContribution = 1000;

	console.log("Deploying CrowdFunding...");
	const proxyContract = await upgrades.deployProxy(crowdFundingfactory, [goal, deadline, minimumContribution, tokenContract.address], {
		initializer: "initialize",
	});
	console.log("CrowdFunding contract deployed to:", proxyContract.address);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
