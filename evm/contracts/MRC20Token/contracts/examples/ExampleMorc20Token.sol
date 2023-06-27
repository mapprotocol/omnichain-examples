// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../MORC20Token.sol";


contract ExampleMorc20Token is MORC20Token {

    mapping(uint256 => uint256) public testList;

    constructor(string memory _name, string memory _symbol, address _mosAddress,uint256 _initialSupply) MORC20Token(_name, _symbol,_mosAddress) {
        _mint(msg.sender,_initialSupply);
    }

}
