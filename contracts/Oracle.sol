// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Oracle {
    uint256 private price;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Oracle: Only owner can set price");
        _;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }
}
