pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IMOSV3.sol";


contract OmniDictionary is Ownable {

    address public mos;

    mapping(string => string) public dictionary;

    mapping(address => bool) public whitelist;

    event AddWhiteList(address indexed _executeAddress, bool _enable);

    event SetMos(address indexed mos);

    event setEntry(string key, string value);

    event sendEntry(uint256 indexed toChain, bytes target, string key, string value);

    constructor() {
    }

    function setDictionaryEntry(string memory _key,string memory _val) external returns(bool) {
        require(whitelist[msg.sender],"access denied");
        dictionary[_key] = _val;

        emit setEntry(_key, _val);
        return true;
    }

    //encode dictionary input (key,value) together with 'setDictionaryEntry' method
    function encodeDictionaryInput(string memory _key,string memory _val) public view returns(bytes memory data){

        data = abi.encodeWithSelector(OmniDictionary.setDictionaryEntry.selector,_key,_val);
    }

    //only whitelist address can acess dictionary setting method
    function setWhiteList(address _executeAddress, bool _enable) external onlyOwner {

        whitelist[_executeAddress] = _enable;
        emit AddWhiteList(_executeAddress, _enable);
    }

    //set the underlying mapo ominichain service contract
    function setMapoService(address _mos) external onlyOwner{

        mos = _mos;
        emit SetMos(_mos);
    }

    //send the custom dictionary input(_key, _value) to the target dictionary address spcified by '_target' on target chain specified by '_tochainId'
    function sendDictionaryInput(uint256 _tochainId,bytes memory _target,string memory _key,string memory _val) external {

        bytes memory data = encodeDictionaryInput(_key,_val);

        IMOSV3.CallData memory cData = IMOSV3.CallData(_target,data,50000,0);

        require(
            IMOSV3(mos).transferOut(
                _tochainId,
                cData
            ),
            "send request failed"
        );

        emit sendEntry(_tochainId, _target, _key, _val);
    }
}
