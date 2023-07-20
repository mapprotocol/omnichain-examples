// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@mapprotocol/mos/contracts/interface/IMOSV3.sol";

contract OAppSourceSender is Ownable {

    IMOSV3 public mos;

    uint256 public cumulativeResult;

    uint256 public constant CROSS_CHIAN_MESSAGE = 0;
    uint256 public constant CROSS_CHIAN_CALL = 1;

    constructor(address _mos){
        mos = IMOSV3(_mos);
    }

    function crossChainAdd(uint256 _number) external {
        require(msg.sender == address(mos),"do not have permission");
        cumulativeResult += _number;
    }

    function _getMessageData(
        uint256 _number,
        bytes memory _target,
        uint256 _type
    )
    internal
    pure
    returns(bytes memory)
    {
        bytes memory messageByte;

        if(_type == CROSS_CHIAN_MESSAGE){
            bytes memory payload = abi.encode(_number);
            IMOSV3.MessageData memory messageData = IMOSV3.MessageData(false,IMOSV3.MessageType.MESSAGE,_target,payload,500000,0);
            messageByte =  abi.encode(messageData);
        }else if(_type == CROSS_CHIAN_CALL){
            bytes memory payload = abi.encodeWithSelector(OAppSourceSender.crossChainAdd.selector,_number);
            IMOSV3.MessageData memory messageData = IMOSV3.MessageData(false,IMOSV3.MessageType.CALLDATA,_target,payload,500000,0);
            messageByte =  abi.encode(messageData);
        }
         return messageByte;
    }

    function _getTransferOutFee(uint256 _toChainId) internal view returns(uint256){
        (uint256 amount,) = mos.getMessageFee(_toChainId,address(0),500000);
        return amount;
    }

    function sendCrossChainAdd(
        uint256 _toChainId,
        uint256 _number,
        bytes memory _target,
        uint256 _type
    )
    external
    returns(bytes32)
    {

        bytes memory messageData = _getMessageData(_number,_target,_type);

        uint256 fee = _getTransferOutFee(_toChainId);

        bytes32 orderId = mos.transferOut{value:fee}(_toChainId, messageData, address(0));

        return orderId;
    }

}