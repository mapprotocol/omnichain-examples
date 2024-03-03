// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@mapprotocol/mos/contracts/interface/IMOSV3.sol";
import "@mapprotocol/mos/contracts/interface/IMapoExecutor.sol";

contract OmniDictionary is Ownable, IMapoExecutor {
    address public mos;

    mapping(string => string) public dictionary;

    mapping(address => bool) public whitelist;

    event AddWhiteList(address indexed _executeAddress, bool _enable);

    event SetMos(address indexed mos);

    event setEntry(string key, string value);

    event sendEntry(uint256 indexed toChain, bytes target, string key, string value);

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    receive() external payable {}

    function setDictionaryEntry(string memory _key, string memory _val) external returns (bool) {
        require(whitelist[msg.sender], "access denied");
        dictionary[_key] = _val;

        emit setEntry(_key, _val);
        return true;
    }

    //encode dictionary input (key,value) together with 'setDictionaryEntry' method
    function encodeDictionaryInput(string memory _key, string memory _val) public pure returns (bytes memory data) {
        data = abi.encodeWithSelector(OmniDictionary.setDictionaryEntry.selector, _key, _val);
    }

    //only whitelist address can acess dictionary setting method
    function setWhiteList(address _executeAddress, bool _enable) external onlyOwner {
        whitelist[_executeAddress] = _enable;
        emit AddWhiteList(_executeAddress, _enable);
    }

    //set the underlying mapo ominichain service contract
    function setMapoService(address _mos) external onlyOwner {
        mos = _mos;
        emit SetMos(_mos);
    }

    //send the custom dictionary input(_key, _value) to the target dictionary address spcified by '_target' on target chain specified by '_tochainId'
    function sendDictionaryInput(
        uint256 _tochainId,
        bytes memory _target,
        string memory _key,
        string memory _val
    ) external payable {
        bytes memory data = encodeDictionaryInput(_key, _val);

        IMOSV3.MessageData memory mData = IMOSV3.MessageData(
            false,
            IMOSV3.MessageType.CALLDATA,
            _target,
            data,
            500000,
            0
        );

        bytes memory mDataBytes = abi.encode(mData);

        (uint256 amount, ) = IMOSV3(mos).getMessageFee(_tochainId, address(0), 500000);

        IMOSV3(mos).transferOut{value: amount}(_tochainId, mDataBytes, address(0));

        emit sendEntry(_tochainId, _target, _key, _val);
    }

    function sendDictionaryMessage(
        uint256 _tochainId,
        bytes memory _target,
        string memory _key,
        string memory _val
    ) external payable {
        bytes memory data = abi.encode(_key, _val);

        IMOSV3.MessageData memory mData = IMOSV3.MessageData(
            false,
            IMOSV3.MessageType.MESSAGE,
            _target,
            data,
            500000,
            0
        );

        bytes memory mDataBytes = abi.encode(mData);

        (uint256 amount, ) = IMOSV3(mos).getMessageFee(_tochainId, address(0), 500000);

        IMOSV3(mos).transferOut{value: amount}(_tochainId, mDataBytes, address(0));

        emit sendEntry(_tochainId, _target, _key, _val);
    }

    function mapoExecute(
        uint256 _fromChain,
        uint256,
        bytes calldata _fromAddress,
        bytes32,
        bytes calldata _message
    ) external override returns (bytes memory newMessage) {
        bool isExecute = IMOSV3(mos).getExecutePermission(address(this), _fromChain, _fromAddress);
        require(isExecute, "Do not have execute permission");

        (string memory key, string memory val) = abi.decode(_message, (string, string));

        dictionary[key] = val;

        return _message;
    }

    function addRemoteCaller(uint256 _fromChain, bytes memory _fromAddress, bool _tag) external {
        IMOSV3(mos).addRemoteCaller(_fromChain, _fromAddress, _tag);
    }
}
