// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SID is ERC20 {
    /**
     * @dev Setting the name and symbol for the SID token.
     *      Mint 100 SID tokens initally
     */
    constructor() ERC20("Sid", "SD") {
        // Intially mint 100 Tokens
        _mint(msg.sender, 100 * 10 ** uint(decimals()));
    }

    /**
     * @dev Making this contract to receive payments
     */
    function receiveFee() public payable {}

    /**
     * @dev returns the contract's balance
     * @return balance of the contract
     */
    function contractBalance() public view returns (uint256 balance) {
        return balanceOf(address(this));
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address.
     * Also, adds 1% fee/tax to the smart contract
     * @param from: sender
     * @param to: recipient
     * @param value: amount of tokens to transfer
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        uint256 fee = value / 100;

        // Transfers the remaing amount (after deducting the fee) to the recipient's account
        super._update(from, to, value - fee);

        // Top-up token contract's balance wiht 1% transfer fee, charged from the sender
        super._update(from, address(this), fee);
    }

    /**
     * @dev Deposits a 'value' to the caller's account.
     * @param value, amount to deposit
     */
    function deposit(uint256 value) external payable virtual {
        _mint(msg.sender, value);
    }
}