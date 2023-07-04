// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../MRC20Token/MORC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

contract Morc20Cappde is MORC20Token,ERC20Capped {
    constructor(string memory _name, string memory _symbol, uint256 _cappde, address _mosAddress) MORC20Token(_name, _symbol, _mosAddress) ERC20Capped(_cappde) {

    }

    function _mint(address account, uint amount) internal virtual override(ERC20, ERC20Capped) {
        ERC20Capped._mint(account, amount);
    }
}
