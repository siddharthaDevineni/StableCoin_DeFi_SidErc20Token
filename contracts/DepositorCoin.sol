// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {SID} from "./SID.sol";

contract DepositorCoin is SID {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "DC: Only owner can mint/burn");
        _;
    }

    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }

    function burn(address from, uint256 value) external onlyOwner {
        _burn(from, value);
    }
}
