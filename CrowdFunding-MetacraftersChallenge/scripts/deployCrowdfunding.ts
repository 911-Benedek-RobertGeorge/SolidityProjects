import { ethers } from "hardhat";

async function main() {
	//TODO ADD CONSTRUCTOR VARIABLE >>> MAYBE ADD AN ADDRESS OF THE SMART CONTRACT TOKEN WAS DEPLOYED ON

	const Factory = await ethers.getContractFactory("CrowdFunding");

	const goal = 100000;
	const deadline = 0;
	const minimumInvestment = 1000;
	const crowdFunding = await Factory.deploy(goal, deadline, minimumInvestment);

	await crowdFunding.deployed(); /// just waiting for the block to be included in a block

	console.log(`CrowdFunding deployed to ${crowdFunding.address} `);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
