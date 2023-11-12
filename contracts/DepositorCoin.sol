// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;
import {SID} from "./SID.sol";

contract DepositorCoin is SID {
    address public owner;
    owner = msg.sender;
    
    public modifier onlyOwner() {
        require(msg.sender == owner, "DC: Only owner can mint/burn");
        _;
    }
    
    function mint(address to, uint256 value) external onlyOwner {
        _mint(to, value);
    }
    
    function burn(address from, uint256 value)  external onlyOwner {
        _burn(from, value);
    }
}