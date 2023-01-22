import { ethers } from "hardhat";

async function main() {
	//TODO ADD CONSTRUCTOR VARIABLE >>> MAYBE ADD AN ADDRESS OF THE SMART CONTRACT TOKEN WAS DEPLOYED ON

	const Factory = await ethers.getContractFactory("CrowdFunding");

	const goal = 1000000000;
	const;
	const crowdFunding = await Factory.deploy();

	await crowdFunding.deployed(); /// just waiting for the block to be included in a block

	console.log(`CrowdFunding deployed to ${crowdFunding.address} `);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
