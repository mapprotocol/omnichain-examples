// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MRC20Token/MORC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract  Morc20BurnableToken is MORC20Token, ERC20Burnable {

    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        uint256 _initialSupply
    )
    MORC20Token(_name, _symbol,_mosAddress)
    {
        _mint(msg.sender,_initialSupply);
    }

}
