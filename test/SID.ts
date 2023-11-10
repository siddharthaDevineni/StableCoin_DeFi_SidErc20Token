import { expect } from "chai";
import { ethers } from "hardhat";

describe("SID", function () {
  it("transfers tokens correctly", async function () {
    const [alice, bob] = await ethers.getSigners();

    const SID = await ethers.getContractFactory("SID");
    const sidToken = await SID.deploy();

    await expect(
      await sidToken.transfer(bob, ethers.parseUnits("10", 18))
    ).to.changeTokenBalances(
      sidToken,
      [alice, bob],
      // differences in the balances between before and after transfer
      [ethers.parseUnits("-10", 18), ethers.parseUnits("10", 18)]
    );
  });
});
