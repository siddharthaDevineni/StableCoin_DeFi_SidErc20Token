// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;
import {SID} from "./SID.sol";
import {DepositorCoin} from "./DepositorCoin.sol";

contract StableCoin is SID {
    DepositorCoin public depositorCoin;

    function mint() external payable {
        uint256 ethUsdPrice = 1000;
        uint256 usdInSCPrice = 1; // 1 USD = 1 SC
        uint256 mintStableCoinAmount = msg.value * ethUsdPrice * usdInSCPrice;
        _mint(msg.sender, mintStableCoinAmount);
    }

    function burn(uint256 burnStableCoinAmount) external {
        _burn(msg.sender, burnStableCoinAmount);
        uint256 ethUsdPrice = 1000;
        uint256 refundingEth = burnStableCoinAmount / ethUsdPrice;

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "SC: Burn refund transaction failed");
    }

    function depositCollateralBuffer() external payable {
        uint256 ethUsdPrice = 1000;
        uint256 surplusInUsd = 500;

        uint256 usdInDCPrice; = depositorCoin.totalSupply() / surplusInUsd;  // 1 USD = 0.5 DC
        uinr256 mintDepositorCoinAmount = msg.value * ethUsdPrice * usdInDCPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer( uint256 burnDepositorCoinAmount ) external () {
        depositorCoin.burn(msg.sender, refundingEth);
        uint256 ethUsdPrice = 1000;
        uint256 surplusInUsd = 500;
        uint256 usdInDCPrice; = depositorCoin.totalSupply() / surplusInUsd;  // 1 USD = 0.5 DC
        uint256 refundingUSD = burnDepositorCoinAmount / usdInDCPrice;
        uint256 refundingEth = refundingUSD / ethUsdPrice;

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "DC:Withdraw collateral buffer transaction failed");
    }
}