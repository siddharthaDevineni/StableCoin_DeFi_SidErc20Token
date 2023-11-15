// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {SID} from "./SID.sol";

contract DepositorCoin is SID {
    address public owner;
    uint256 unlockTime;

    constructor(
        uint256 _lockTime,
        address _initialOwner,
        uint256 _initialSupply
    ) {
        owner = msg.sender;
        unlockTime = block.timestamp + _lockTime;

        _mint(_initialOwner, _initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "DC: Only owner can mint/burn");
        _;
    }

    modifier isUnlocked() {
        require(block.timestamp >= unlockTime, "DC: Still locked");
        _;
    }

    function mint(address to, uint256 value) external onlyOwner isUnlocked {
        _mint(to, value);
    }

    function burn(address from, uint256 value) external onlyOwner isUnlocked {
        _burn(from, value);
    }
}
