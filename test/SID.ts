import { expect, should } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("SID", function () {
  async function deploySidTokenERC20() {
    const [alice, bob] = await ethers.getSigners();

    const SID = await ethers.getContractFactory("SID");
    const sidToken = await SID.deploy();
    return { alice, bob, sidToken };
  }
  it("should transfer tokens correctly", async function () {
    const { alice, bob, sidToken } = await loadFixture(deploySidTokenERC20);
    console.log(
      "Balance of Alice after minting 100 tokens to her: ",
      ethers.formatEther(await sidToken.balanceOf(alice))
    );
    console.log(
      "Balance of Bob before the transfer: ",
      ethers.formatEther(await sidToken.balanceOf(bob))
    );
    console.log(
      "Balance of token contract before transfer: ",
      ethers.formatEther(await sidToken.contractBalance())
    );

    await expect(
      await sidToken.transfer(bob, ethers.parseUnits("10", 18))
    ).to.changeTokenBalances(
      sidToken,
      [alice, bob],
      // differences in the balances between before and after transfer
      [ethers.parseUnits("-10", 18), ethers.parseUnits("99", 17)]
    );

    console.log(
      "Balance of Alice after she transfers 10 tokens to Bob: ",
      ethers.formatEther(await sidToken.balanceOf(alice))
    );
    console.log(
      "Balance of Bob after he receives the tokens: ",
      ethers.formatEther(await sidToken.balanceOf(bob))
    );
    console.log(
      "Balance of token contract after transfer: ",
      ethers.formatEther(await sidToken.contractBalance())
    );

    await expect(
      await sidToken.connect(bob).transfer(alice, ethers.parseUnits("5", 18))
    ).to.changeTokenBalances(
      sidToken,
      [alice, bob],
      // differences in the balances between before and after transfer
      [ethers.parseUnits("4.95", 18), ethers.parseUnits("-5", 18)]
    );

    console.log(
      "Balance of Alice after Bob transfers 5 tokens to her: ",
      ethers.formatEther(await sidToken.balanceOf(alice))
    );
    console.log(
      "Balance of Bob after he transferred those 5 tokens: ",
      ethers.formatEther(await sidToken.balanceOf(bob))
    );
    console.log(
      "Balance of token contract after transfer: ",
      ethers.formatEther(await sidToken.contractBalance())
    );
  });

  it("should revert on insufficient balance", async () => {
    const { alice, bob, sidToken } = await loadFixture(deploySidTokenERC20);

    await expect(sidToken.transfer(bob, ethers.parseUnits("200", 18))).to.be
      .reverted;
  });

  it("should deposit to the caller's account", async () => {
    const { alice, bob, sidToken } = await loadFixture(deploySidTokenERC20);

    console.log(
      "Balance of Alice before her deposit: ",
      ethers.formatEther(await sidToken.balanceOf(alice))
    );

    await expect(
      await sidToken.deposit(ethers.parseUnits("50", 18))
    ).to.changeTokenBalance(sidToken, alice, ethers.parseUnits("49.5", 18));

    console.log(
      "Balance of Alice after deposit: ",
      ethers.formatEther(await sidToken.balanceOf(alice))
    );
  });
});
