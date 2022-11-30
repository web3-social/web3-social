import { randomBytes } from "node:crypto";
import * as hrt from "hardhat";
import Web3 from "web3";
import { TestSign__factory } from "../typechain-types";

async function main() {

    const web3 = new Web3();

    const profilePrivateKey = randomBytes(32).toString('hex');
    const profileAccount = web3.eth.accounts.privateKeyToAccount(profilePrivateKey);
    console.log('profile address', profileAccount.address);

    const testSignFactory = await hrt.ethers.getContractFactory("TestSign") as TestSign__factory;
    const testSign = await testSignFactory.deploy(profileAccount.address);
    await testSign.deployed();

    const msg = web3.utils.encodePacked(
        { value: testSign.address, type: "address" },
        { value: profileAccount.address, type: "address" },
    )!;

    console.log('contract address', testSign.address);

    const sig = profileAccount.sign(msg);
    console.log(sig);

    await testSign.verify(sig.signature);
    await testSign.verify(sig.signature);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });