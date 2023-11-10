import { expect } from "chai";
import { ethers } from "hardhat";

describe("SID", function () {
  it("transfers tokens correctly", async function () {
    const [alice, bob] = await ethers.getSigners();

    const SID = await ethers.getContractFactory("SID");
    const sidToken = await SID.deploy();

    const aliceBalance = await sidToken.balanceOf(alice.address);
    const bobBalance = await sidToken.balanceOf(bob.address);

    expect(aliceBalance).to.equals(ethers.parseUnits("90", 18));
    expect(bobBalance).to.equals(ethers.parseUnits("9", 18));
  });
});
