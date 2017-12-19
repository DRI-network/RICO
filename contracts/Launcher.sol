pragma solidity ^0.4.18;

import "./PoDs/DutchAuctionPoD.sol";
import "./PoDs/SimplePoD.sol";
import "./PoDs/KaitsukePoD.sol";
import "./RICO.sol";

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE
/// @notice TokenRound chose a index for pod execute modes. 
/// 0. Attach ToB pod. podType == 101
/// 1~ Attach Custom pod. podType == 111

contract Launcher {

  /**
   * Storage
   */
  string public name = "RICO Launcher";
  string public version = "0.9.2";

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function Launcher() public { }

  /**
   * @dev newToken token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name of RICO format.
   * @param _symbol       set Token symbol of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   */
  function kickStart(
    address _rico,
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    uint _mode,
    uint256[] _params
  ) 
  public 
  {
    if (_mode == 0) {
      address[] memory pods = new address[](2);
      KaitsukePoD tob = new KaitsukePoD();
      tob.setConfig(_decimals, uint256(_params[0]), uint256(_params[1]), msg.sender);
      tob.init(msg.sender, uint256(_params[2]));
      pods[0] = address(tob);

      SimplePoD pod = new SimplePoD();
      pod.setConfig(_decimals, uint256(_params[3]), uint256(_params[4]));
      pod.init(msg.sender, uint256(_params[5]));
      pods[1] = address(pod);

      RICO rico = RICO(_rico);
      rico.newProject(_name, _symbol, _decimals, pods);
    }
  }
}