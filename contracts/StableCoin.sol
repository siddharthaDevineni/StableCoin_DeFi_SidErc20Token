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
    uint256 depositorCoinLockTime;

    constructor(
        uint256 _feeRatePercentage,
        uint256 _initialCollaterRatioPercentage,
        uint256 _depositorCoinLockTime
    ) {
        feeRatePercentage = _feeRatePercentage;
        initialCollaterRatioPercentage = _initialCollaterRatioPercentage;
        depositorCoinLockTime = _depositorCoinLockTime;
    }

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

    /**
     * @dev deposit Depositor coins as buffer on top of stable coins in the contract so that stable coin holders are safe
     * deposits in the case of an already existing buffer or in an under water situation to bring stable coin holders out of risk
     */
    function depositCollateralBuffer() external payable {
        int256 surplusOrDeficitInUsd = _getSurplusOrDeficitInContractInUsd();

        if (
            surplusOrDeficitInUsd <= 0
        ) // when there is an under water situation
        {
            uint256 deficitInUsd = uint256(surplusOrDeficitInUsd * -1);
            uint256 deficitInEth = deficitInUsd / oracle.getPrice();

            uint256 addedSurplusEth = msg.value - deficitInEth;

            uint256 requiredInitialSurplusInUsd = (initialCollaterRatioPercentage *
                    this.totalSupply()) / 100;
            uint256 requiredInitialSurplusInEht = requiredInitialSurplusInUsd /
                oracle.getPrice();

            require(
                addedSurplusEth >= requiredInitialSurplusInEht,
                "SC: Inital collateral ratio not matched"
            );

            uint256 mintInitalDepositorSupply = addedSurplusEth *
                oracle.getPrice();

            depositorCoin = new DepositorCoin(
                depositorCoinLockTime,
                msg.sender,
                mintInitalDepositorSupply
            );

            return;
        }
        uint256 surplusInUsd = uint256(surplusOrDeficitInUsd);

        // usdInDCPrice = 250e18 / 500e18 = 0.5
        uint256 usdInDCPrice = depositorCoin.totalSupply() / surplusInUsd;

        uint256 mintDepositorCoinAmount = msg.value *
            oracle.getPrice() *
            usdInDCPrice;
        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    /**
     * @dev withdraw Depositor coins from the buffer
     * @param burnDepositorCoinAmount: the amount in USD to withdraw equivalent DCs
     */
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

    /**
     * @dev calculates either surplus or deficit of SCs in USD to check if it's in under water or surplus situations
     * @return surplusOrDeficitInUsd: Surplus or deficit amount of SCs
     */
    function _getSurplusOrDeficitInContractInUsd()
        private
        view
        returns (int256)
    {
        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) *
            oracle.getPrice();
        uint256 totalSCBalanceInUsd = totalSupply();
        int256 surplusOrDeficitInUsd = int256(ethContractBalanceInUsd) -
            int256(totalSCBalanceInUsd);
        return surplusOrDeficitInUsd;
    }
}
