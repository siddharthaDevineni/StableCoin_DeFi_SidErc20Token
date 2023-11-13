// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {SID} from "./SID.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "Oracle.sol";

contract StableCoin is SID {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;

    function mint() external payable {
        uint256 usdInSCPrice = 1; // 1 USD = 1 SC
        uint256 fee = _getFee(msg.value);
        uint256 mintStableCoinAmount = ( msg.value - fee )* oracle.getPrice() * usdInSCPrice;
        _mint(msg.sender, mintStableCoinAmount);
    }

    function burn(uint256 burnStableCoinAmount) external {
        _burn(msg.sender, burnStableCoinAmount);
        uint256 refundingEth = burnStableCoinAmount / oracle.getPrice();

        uint256 fee = _getFee(refundingEth);
        (bool success, ) = msg.sender.call{value: refundingEth - fee}("");
        require(success, "SC: Burn refund transaction failed");
    }

    function _getFee(uint256 ethAmount) private view returns (uint256) {
        ethAmount * feeRatePercentage / 100 ;
    }

    function depositCollateralBuffer() external payable {
        uint256 surplusInUsd = _getSurplusInContractInUsd();

        uint256 usdInDCPrice = depositorCoin.totalSupply() / surplusInUsd;  // 1 USD = 0.5 DC
        uinr256 mintDepositorCoinAmount = msg.value * oracle.getPrice() * usdInDCPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer( uint256 burnDepositorCoinAmount ) external () {
        depositorCoin.burn(msg.sender, refundingEth);
        uint256 surplusInUsd = _getSurplusInContractInUsd();
        uint256 usdInDCPrice = depositorCoin.totalSupply() / surplusInUsd;  // 1 USD = 0.5 DC
        uint256 refundingUSD = burnDepositorCoinAmount / usdInDCPrice;
        uint256 refundingEth = refundingUSD / oracle.getPrice();

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "DC:Withdraw collateral buffer transaction failed");
    }

    function _getSurplusInContractInUsd() private view returns (uint256) {
        uint256 ethContractBalanceInUsd = (contractBalance() - msg.value) * oracle.getPrice();
        uint256 totalSCBalanceInUsd =  totalSupply();
        uint256 surplusInContract = ethContractBalanceInUsd - totalSCBalanceInUsd;
        return surplusInContract;
    }
}