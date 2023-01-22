import { ethers } from "hardhat";

async function main() {
	const Factory = await ethers.getContractFactory("TokenICO.sol");

	const tokenContract = await Factory.deploy();

	await tokenContract.deployed(); /// just waiting for the block to be included in a block

	console.log(`BenBurgerToken deployed to ${tokenContract.address} `);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
