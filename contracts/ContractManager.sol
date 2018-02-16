pragma solidity ^0.4.18;

import "./PoDs/SimplePoD.sol";
import "./PoDs/TokenMintPoD.sol";

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

/**
 * @title   ContractManager
 * @dev     Takes care of initializing the SimplePoD.sol and TokenMintPoD.sol
 *          
 *          RICO.sol, Launcher.sol and ContractManager.sol, are the three contracts
 *          that have to be deployed on the network on beforehand.
 *          Please see the 2_deploy_contracts.js migration for the details.
 *          
 *          The ContractManager was extracted out of the Launcher because
 *          deploying Launcher.sol onto the network was too expensive.
 */
contract ContractManager {

  /**
   * Storage
   */
  string public name = "ContractManager";
  string public version = "0.9.3";

  /**
   * constructor
   */
  function ContractManager() public {}

  /**
   * @dev    deploy a new contract instance.
   * 
   * @param  _rico      address of rico.
   * @param  _mode      Token name of RICO format.
   * @param  _decimals  Token decimals of RICO format.
   * @param  _wallet    Project owner's multisig wallet.
   * @param  _params    array         parameters of the PoD.
   *                    These parameters differ when initializing SimplePoD or TokenMintPoD.
   *                    Please check Launcher.sol for which parameters are being sent.
   * 
   * @return address
   */
  function deploy( 
    address _rico, 
    uint _mode,
    uint8 _decimals, 
    address _wallet,
    uint256[] _params
  ) 
  public returns (address) 
  {
    if (_mode == 0) {
      SimplePoD pod = new SimplePoD();
      pod.init(_wallet, _decimals, _params[0], _params[1], _params[2]);
      pod.transferOwnership(_rico);
      return address(pod);
    }
    if (_mode == 1) {
      TokenMintPoD mint = new TokenMintPoD();
      mint.init(_wallet, _params[0], _params[1]);
      mint.transferOwnership(_rico);
      return address(mint);
    }
  }
}

