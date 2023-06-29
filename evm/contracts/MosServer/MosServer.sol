// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IMOSV3.sol";
import "../interfaces/IMapoExecutor.sol";

abstract contract MosServer is Ownable, IMapoExecutor {
    IMOSV3 public mos;


    uint256 public constant MESSAGE_TYPE_MESSAGE = 0;
    uint256 public constant MESSAGE_TYPE_CALLDATE = 1;

    uint256 public constant INTERCHAIN_GASLIMIT = 50000;

    address public feeTokenAddress;

    mapping(uint256 => bytes) trustedList;

    event SetTrustedList(uint256 _toChainId,bytes _toAddress);
    event SetFeeToken(address _feeToken);

    constructor(address _mosAddress) {
        mos = IMOSV3(_mosAddress);
    }

    function mapoExecute(
        uint256 _fromChain,
        uint256 _toChain,
        bytes calldata _fromAddress,
        bytes32 _orderId,
        bytes calldata _message
    ) external virtual override returns(bytes memory newMessage){
        require(_msgSender() == address(mos), "MosServer: invalid mos caller");

        bytes memory tempFromAddress = trustedList[_fromChain];

        require(_fromAddress.length == tempFromAddress.length && tempFromAddress.length > 0 && keccak256(_fromAddress) == keccak256(tempFromAddress),
            "MosServer: invalid source chain contract address");

        _tokenExecute(_fromChain,_toChain,_fromAddress,_orderId,_message);

        newMessage = _message;
    }

    function _tokenExecute(
        uint256 _fromChain,
        uint256 _toChain,
        bytes memory _fromAddress,
        bytes32 _orderId,
        bytes memory _message
    ) internal virtual;

    function _mosTransferOut(
        uint256 _toChianId,
        uint256 _toType,
        bytes memory _payload,
        uint256 _gasLimit,
        address _feeToken
    )internal virtual returns(bytes32) {
        bytes memory tempFromAddress = trustedList[_toChianId];
        require(tempFromAddress.length > 0, "MosServer: The destination address is untrusted");
        bytes memory messageDataBytes;
        if(_toType == MESSAGE_TYPE_MESSAGE){
            messageDataBytes = abi.encode(false,IMOSV3.MessageType.MESSAGE,tempFromAddress,_payload,_gasLimit,0);
        }else if(_toType == MESSAGE_TYPE_CALLDATE){
            messageDataBytes = abi.encode(false,IMOSV3.MessageType.CALLDATA,tempFromAddress,_payload,_gasLimit,0);
        }else{
            require(false,"MosServer:Cross-chain type not fit");
        }

        (uint256 fee,) = mos.getMessageFee(_toChianId,_feeToken,_gasLimit);
        require(fee > 0,"MosServer: void fee");

        return mos.transferOut{value:fee}(_toChianId,messageDataBytes,_feeToken);

    }

    function setTrustedList(uint256 _toChainId,bytes memory _toAddress) external onlyOwner {
        trustedList[_toChainId] = _toAddress;
        emit SetTrustedList(_toChainId,_toAddress);
    }

    function getTrustedAddress(uint256 _toChainId) external view returns(bytes memory){
        return trustedList[_toChainId];
    }

    function setFeeToken(address _feeToken)external onlyOwner{
        feeTokenAddress = _feeToken;
        emit SetFeeToken(_feeToken);
    }
}
