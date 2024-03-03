// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../morc20/MORC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract MORC20MintableToken is MORC20Token, ERC20Burnable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply,
        address _owner
    ) MORC20Token(_name, _symbol, _mosAddress) {
        _transferOwnership(_owner);
        _mint(_owner, _initialSupply);
    }

    function mint(address _receiveAddress, uint256 _amount) public virtual onlyOwner {
        _mint(_receiveAddress, _amount);
    }
}
