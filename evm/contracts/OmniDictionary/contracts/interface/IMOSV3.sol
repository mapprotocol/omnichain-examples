// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IMOSV3 {

    enum chainType{
        NULL,
        EVM,
        NEAR
    }

    enum MessageType {
        CALLDATA,
        MESSAGE
    }

    struct MessageData {
        bool relay;
        MessageType msgType;
        bytes target;
        bytes payload;
        uint256 gasLimit;
        uint256 value;
    }

    function transferOut(uint256 _toChain, bytes memory _messageData,address _feeToken) external payable  returns(bool);

    function addRemoteCaller(uint256 _fromChain, bytes memory _fromAddress,bool _tag) external;

    function getMessageFee(uint256 _toChain, address _feeToken, uint256 _gasLimit) external view returns(uint256, address);

    function callerList(address _mos,uint256 _fromchain,bytes memory _fromAddress) external returns(bool _tag);

    event mapMessageOut(uint256 indexed fromChain, uint256 indexed toChain,bytes32 orderId, bytes callData);

    event mapMessageIn(uint256 indexed fromChain, uint256 indexed toChain, bytes32 orderId, bool executeTag);

}