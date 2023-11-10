import { expect } from "chai";
import { ethers, network } from "hardhat";

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
      [ethers.parseUnits("-10", 18), ethers.parseUnits("9", 18)]
    );

    console.log(
      "Current balance of Alice: ",
      (await sidToken.balanceOf(alice)).toString()
    );
    console.log(
      "Current balance of Bob  : ",
      (await sidToken.balanceOf(bob)).toString()
    );
    console.log(
      "Current balance of token contract  : ",
      (await sidToken.contractBalance()).toString()
    );

    await expect(
      await sidToken.connect(bob).transfer(alice, ethers.parseUnits("5", 18))
    ).to.changeTokenBalances(
      sidToken,
      [alice, bob],
      // differences in the balances between before and after transfer
      [ethers.parseUnits("45", 17), ethers.parseUnits("-5", 18)]
    );
  });
});
