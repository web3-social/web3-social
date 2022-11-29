import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Resolver, Resolver__factory, TestProfile, TestProfile__factory } from "../typechain-types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";


describe("Integeration test", function () {
  async function deploy() {
    const [owner, profileA, profileB, otherAccount] = await ethers.getSigners();

    
    const resolverFactory = await ethers.getContractFactory("Resolver") as Resolver__factory;
    const resolver = await resolverFactory.deploy() as Resolver;

    const profileFactory = await ethers.getContractFactory("TestProfile") as TestProfile__factory;
    const profileInstanceA = await profileFactory.deploy(profileA.address) as TestProfile;
    const profileInstanceB = await profileFactory.deploy(profileB.address) as TestProfile;

    const init = async (account: SignerWithAddress, contract: TestProfile) => {
      const sign = async (account: SignerWithAddress, contractAddress: string): Promise<string> => {
        const msg = ethers.utils.solidityPack(["address", "address"], [contractAddress, account.address]);
        return await account.signMessage(ethers.utils.arrayify(msg));
      };

      await contract.setResolver(resolver.address);
      const sig = await sign(account, contract.address);
      await contract.setSignature(sig);
    };

    await init(profileA, profileInstanceA);
    await init(profileB, profileInstanceB);

    return { resolver, owner, profileA, profileB, profileInstanceA, profileInstanceB };
  }

  describe("basic function", function () {
    it("follow", async function () {
      const { resolver, owner, profileA, profileB, profileInstanceA, profileInstanceB } = await loadFixture(deploy);
      await profileInstanceA.follow(profileB.address);
    });
    it("post", async function () {
      const { resolver, owner, profileA, profileB, profileInstanceA, profileInstanceB } = await loadFixture(deploy);
      
      const sign = async (account: SignerWithAddress, nonce: BigNumber, content: string) => {
        const msg = ethers.utils.solidityPack(
          ["address", "uint256", "address", "uint256", "bytes32"], 
          [account.address, nonce, account.address, nonce, ethers.utils.keccak256(ethers.utils.solidityPack(["string"], [content]))]
        );
        return await account.signMessage(ethers.utils.arrayify(msg));
      };
      
      const nonce = await profileInstanceA.callStatic.getNonce();
      const content = "ipfs://foo";
      const sig = await sign(profileA, nonce, content);
      await profileInstanceA.post(content, sig);
      
      const signReply = async (account: SignerWithAddress, postProfile: string, nonce: BigNumber, replyNonce: BigNumber, content: string) => {
        const msg = ethers.utils.solidityPack(
          ["address", "uint256", "address", "uint256", "bytes32"], 
          [postProfile, nonce, account.address, replyNonce, ethers.utils.keccak256(ethers.utils.solidityPack(["string"], [content]))]
        );
        return await account.signMessage(ethers.utils.arrayify(msg));
      };
      
      const replyNonce = await profileInstanceA.callStatic.getReplyNonce(0);
      const replyContent = "ipfs://bar";
      const replysig = await signReply(profileB, profileA.address, nonce, replyNonce, replyContent);
      await profileInstanceB.reply(profileA.address, 0, replyNonce, replyContent, replysig);
    });
  });
});
