// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../morc20/MORC20Token.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract MORC20Pausable is MORC20Token,Pausable {
    constructor(string memory _name, string memory _symbol, address _mosAddress) MORC20Token(_name, _symbol,_mosAddress) {
    }

    function _sendCrossChainToken(
        address _fromAddress,
        uint256 _toChainId,
        bytes memory _toAddress,
        uint256 _fromAmount
    ) internal virtual override whenNotPaused returns (uint256 amount,uint256 decimals){
        return super._sendCrossChainToken(_fromAddress, _toChainId, _toAddress, _fromAmount);
    }

    function pauseSendTokens(bool pause) external onlyOwner {
        pause ? _pause() : _unpause();
    }

}
