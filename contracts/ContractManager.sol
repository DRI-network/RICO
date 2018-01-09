pragma solidity ^0.4.18;

import "./PoDs/SimplePoD.sol";
import "./PoDs/DutchAuctionPoD.sol";
import "./PoDs/TokenMintPoD.sol";

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE


contract ContractManager {

  /**
   * Storage
   */
  string public name = "ContractManager";
  string public version = "0.9.3";
  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function ContractManager() public {}

  /**
   * @dev newToken token meta Data implement for ERC-20 Token Standard Format.
   * @param _mode         set Token name of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   */

  function deploy(  
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
      return address(pod);
    }
    if (_mode == 1) {
      TokenMintPoD mint = new TokenMintPoD();
      mint.init(_wallet, _params[0], _params[1]);
      return address(mint);
    }

    if (_mode == 2) {
      DutchAuctionPoD auction = new DutchAuctionPoD();
      auction.init(_wallet, _decimals, _params[0], _params[1], uint32(_params[2]), _params[3]);
      return address(auction);
    }
    
  }
}

