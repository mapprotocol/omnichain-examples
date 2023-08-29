// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@mapprotocol/mos/contracts/interface/IMOSV3.sol";
import "@mapprotocol/mos/contracts/interface/IMapoExecutor.sol";

contract OAppTargetReceiver is Ownable, IMapoExecutor{

    IMOSV3 public mos;

    uint256 public cumulativeResult;
    mapping(bytes32 => bool) orderList;

    constructor(address _mos){
        mos = IMOSV3(_mos);
    }

    function crossChainAdd(uint256 _number) external {
        require(msg.sender == address(mos),"do not have permission");
        cumulativeResult += _number;
    }

   function mapoExecute(
       uint256 _fromChain,
       uint256 _toChain,
       bytes calldata _fromAddress,
       bytes32 _orderId,
       bytes calldata _message
   ) external returns(bytes memory newMessage){
        require(!orderList[_orderId],"The orderId is invalid");
        (bytes32 typeTag,bytes memory payload) = abi.decode(_message,(bytes32,bytes));
        uint256 number = abi.decode(payload,(uint256));
        cumulativeResult += number;
        orderList[_orderId] = true;
        return _message;
   }


    function getCumulativeResult() external view returns(uint256){
        return cumulativeResult;
    }


    function setTrustFromAddress(uint256 _sourceChainId, bytes memory _sourceAddress, bool _tag) external onlyOwner {
        mos.addRemoteCaller(_sourceChainId,_sourceAddress,_tag);
    }

    function getTrustFromAddress(address _targetAddress,uint256 _sourceChainId,bytes memory _sourceAddress) external view returns(bool){
        return mos.getExecutePermission(_targetAddress,_sourceChainId,_sourceAddress);
    }

}