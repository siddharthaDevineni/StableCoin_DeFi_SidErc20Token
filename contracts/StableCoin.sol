// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {SID} from "./SID.sol";
import {DepositorCoin} from "./DepositorCoin.sol";
import {Oracle} from "./Oracle.sol";

contract StableCoin is SID {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 initialCollaterRatioPercentage;

    function mint() external payable {
        uint256 usdInSCPrice = 1; // 1 USD = 1 SC
        uint256 fee = _getFee(msg.value);
        uint256 mintStableCoinAmount = (msg.value - fee) *
            oracle.getPrice() *
            usdInSCPrice;
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
        return (ethAmount * feeRatePercentage) / 100;
    }

    function depositCollateralBuffer() external payable {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();

        uint256 usdInDCPrice;
        uint256 addedSurplusEth;

        if (surplusOrDeficitInUsd <= 0) {
            uint256 deficitInUsd = uint256(surplusOrDeficitInUsd * -1);
            uint256 deficitInEth = deficitInUsd / oracle.getPrice();

            addedSurplusEth = msg.value - deficitInEth;

            uint256 requiredInitialSurplusInUsd = (initialCollaterRatioPercentage *
                    this.totalSupply()) / 100;
            uint256 requiredInitialSurplusInEht = requiredInitialSurplusInUsd /
                oracle.getPrice();

            require(
                addedSurplusEth >= requiredInitialSurplusInEht,
                "SC: Inital collateral ratio not matche"
            );
            depositorCoin = new DepositorCoin();
            usdInDCPrice = 1;
        } else {
            uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
            usdInDCPrice = depositorCoin.totalSupply() / surplusInUsd;
            addedSurplusEth = msg.value;
        }
        uint256 mintDepositorCoinAmount = addedSurplusEth *
            oracle.getPrice() *
            usdInDCPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(
        uint256 burnDepositorCoinAmount
    ) external {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();
        require(surplusOrDeficitInUsd > 0, "SC: No DC to withdraw");

        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);
        uint256 usdInDCPrice = depositorCoin.totalSupply() / surplusInUsd; // 1 USD = 0.5 DC
        uint256 refundingUSD = burnDepositorCoinAmount / usdInDCPrice;
        uint256 refundingEth = refundingUSD / oracle.getPrice();
        depositorCoin.burn(msg.sender, refundingEth);

        (bool success, ) = msg.sender.call{value: refundingEth}("");
        require(success, "DC:Withdraw collateral buffer transaction failed");
    }

    function _getSurplusOrDeficitInContractInUsd()
        private
        view
        returns (int256)
    {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) *
            oracle.getPrice();
        uint256 totalSCBalanceInUsd = totalSupply();
        int256 surplusInContract = int256(ethContractBalanceInUsd) -
            int256(totalSCBalanceInUsd);
        return surplusInContract;
    }
}
