pragma solidity ^0.4.18;

import "./ContractManager.sol";
import "./PoDs/RICOStandardPoD.sol";
import "./RICO.sol";

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract Launcher {

  /**
   * Storage
   */
  string public name = "RICO Launcher";
  string public version = "0.9.3";
  RICO public rico;
  ContractManager public cm;
  bool state = false;
  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function Launcher() public {}

  /**
   * @dev init rico contract.
   * @param _rico         set rico address.
   */
  function init(address _rico, address _cm) public {
    require(!state);
    rico = RICO(_rico);
    cm = ContractManager(_cm);
    state = true;
  }


  /**
   * @dev standardICO uses 2 pods RICOStandardPoD and SimplePoD.
   * @param _name         Token name of RICO format.
   * @param _symbol       Token symbol of RICO format.
   * @param _decimals     Token decimals of RICO format.
   * @param _wallet       Founder's multisigWallet.
   * @param _tobParams    params of RICOStandardPoD pod.
   * @param _podParams    params of SimplePoD pod.
   * @param _owners       array of owners address, 0:tob executor, 1: founder.
   * @param _marketMakers array of marketMakers address of project 
   */

  function standardICO(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address _wallet,
    uint256[] _tobParams,
    uint256[] _podParams,
    address[2] _owners,
    address[] _marketMakers
  ) 
  public returns (address)
  {
    address[] memory pods = new address[](2);

    RICOStandardPoD tob = new RICOStandardPoD();
    tob.init(_decimals, _tobParams[0], _tobParams[1], _tobParams[2], _owners, _marketMakers, _tobParams[3]);
    tob.transferOwnership(rico);

    pods[0] = address(tob);
    pods[1] = cm.deploy(rico, 0, _decimals, _wallet, _podParams);

    return rico.newProject(_name, _symbol, _decimals, pods, _wallet);
  }


  /**
   * @dev simpleICO uses 2 pods SimplePoD and TokenMintPoD.
   * @param _name         Token name of RICO format.
   * @param _symbol       Token symbol of RICO format.
   * @param _decimals     Token decimals of RICO format.
   * @param _wallet       Founder's multisigWallet.
   * @param _podParams    params of SimplePoD pod.
   * @param _mintParams   params of TokenMintPoD pod.
   */

  function simpleICO(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address _wallet,
    uint256[] _podParams,
    uint256[] _mintParams
  ) 
  public returns (address)
  {
    address[] memory pods = new address[](2);
    pods[0] = cm.deploy(rico, 0, _decimals, _wallet, _podParams);
    pods[1] = cm.deploy(rico, 1, _decimals, _wallet, _mintParams);

    return rico.newProject(_name, _symbol, _decimals, pods, _wallet);

  }
}

