import { ethers } from "hardhat";

async function main() {
	const Factory = await ethers.getContractFactory("TokenICO");

	const tokenContract = await Factory.deploy("0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199"); /// add this to dotenv

	await tokenContract.deployed(); /// just waiting for the block to be included in a block

	console.log(`BenBurgerToken ICO deployed to ${tokenContract.address} `);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
