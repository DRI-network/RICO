pragma solidity ^0.4.18;

import "./ContractManager.sol";
import "./PoDs/RICOStandardPoD.sol";
import "./RICO.sol";

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

/**
 * @title   Launcher
 * @dev     Launcher for deploying the Proof of Donation (PoD) contracts with custom variables.
 *          RICO.sol, Launcher.sol and ContractManager.sol, are the three contracts
 *          that have to be deployed on the network on beforehand.
 *          Please see the 2_deploy_contracts.js migration for the details.
 *          
 * @dev     After deploying Launcher.sol and RICO.sol to the network it's important
 *          you register the addresse of RICO.sol and ContractManager.sol in this Launcher.
 *          Please see the 2_deploy_contracts.js migration for the details.
 */
contract Launcher {

  /**
   * Storage
   */
  string public name = "RICO Launcher";
  string public version = "0.9.3";
  RICO public rico;
  ContractManager public cm;
  bool public initialized = false;

  /**
   * constructor
   */
  function Launcher() public {}

  /**
   * @dev   Register the RICO contract address in the Launcher.
   * @param _rico        RICO's contract address
   */
  function init(address _rico, address _cm) public {
    require(!initialized);
    rico = RICO(_rico);
    cm = ContractManager(_cm);
    initialized = true;
  }

  /**
   * @dev standardICO uses 2 pods RICOStandardPoD and PublicSalePoD.
   * @param _name             Token name of RICO format.
   * @param _symbol           Token symbol of RICO format.
   * @param _decimals         Token decimals of RICO format.
   * @param _wallet           Project owner's multisig wallet.
   * @param _tobParams        array                   params of RICOStandardPoD pod.
   *        _tobParams[0]     _startTimeOfTOB         (see RICOStandardPoD.sol)
   *        _tobParams[1]     _allocationOfTokens     (see RICOStandardPoD.sol)
   *        _tobParams[2]     _priceInWei             (see RICOStandardPoD.sol)
   *        _tobParams[3]     _secondOwnerAllocation  (see RICOStandardPoD.sol)
   * @param _podParams        array                   params of PublicSalePoD pod.
   *        _podParams[0]     _startTimeOfPoD         (see PublicSalePoD.sol)
   *        _podParams[1]     _capOfToken             (see PublicSalePoD.sol)
   *        _podParams[2]     _capOfWei               (see PublicSalePoD.sol)
   * @param _tobAddresses     array                   owner addresses for the Take Over Bid (TOB).
   *        _tobAddresses[0]  TOB Funder
   *        _tobAddresses[1]  TOB second owner (can receive set allocation)
   * @param _marketMakers     array of marketMakers address of project.
   */
  function standardICO(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address _wallet,
    uint256[] _tobParams,
    uint256[] _podParams,
    address[2] _tobAddresses,
    address[] _marketMakers
  ) 
  public returns (address)
  {
    address[] memory pods = new address[](2);

    RICOStandardPoD rsp = new RICOStandardPoD();

    rsp.init(_decimals, _tobParams[0], _tobParams[1], _tobParams[2], _tobAddresses, _marketMakers, _tobParams[3]);
    rsp.transferOwnership(rico);

    pods[0] = address(rsp);
    pods[1] = cm.deploy(rico, 0, _decimals, _wallet, _podParams);

    return rico.newProject(_name, _symbol, _decimals, pods, _wallet);
  }

  /**
   * @dev simpleICO uses 2 pods PublicSalePoD and TokenMintPoD.
   * @param _name          Token name of RICO format.
   * @param _symbol        Token symbol of RICO format.
   * @param _decimals      Token decimals of RICO format.
   * @param _wallet        Project owner's multisig wallet.
   * @param _podParams     array               params of PublicSalePoD pod.
   *        _podParams[0]  _startTimeOfPoD     (see PublicSalePoD.sol)
   *        _podParams[1]  _capOfToken         (see PublicSalePoD.sol)
   *        _podParams[2]  _capOfWei           (see PublicSalePoD.sol)
   * @param _mintParams    array               params of TokenMintPoD pod.
   *        _mintParams[0] _allocationOfTokens (see TokenMintPod.sol)
   *        _mintParams[1] _lockTime           (see TokenMintPod.sol)
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
