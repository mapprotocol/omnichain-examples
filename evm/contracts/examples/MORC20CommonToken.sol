// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../morc20/MORC20Token.sol";

contract MORC20CommonToken is MORC20Token {
    constructor(
        string memory _name,
        string memory _symbol,
        address _mosAddress,
        address _owner
    )
    MORC20Token(_name, _symbol,_mosAddress)
    {
        _transferOwnership(_owner);
    }


}
