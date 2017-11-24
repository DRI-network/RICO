pragma solidity ^0.4.18;
import "./Ownable.sol";
/// @title Freezable - Freezable contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract Freezable is Ownable {

  /**
   * Storage
   */
  address owner;
  bool executable;
  bool cold;

  /**
   * Modifier
   */

  modifier can() {
    require(executable);
    _;
  }

  /**
   * @notice Constructor method
   * @dev Constructor is called when contract deployed.
   */
  function Freezable() public {
    executable = true;
    cold = false;
  }

  /**
   * functions
   */

  /// @notice set to be stop all executable functions temporarily if occurring emergencies.
  /// @dev pause is called by Owner.
  /// @param _flag param represent a lock flag value 1 or 0 
  function pause(bool _flag) public onlyOwner() returns (bool) {
    require(!cold);
    executable = _flag;
    return executable;
  }
  /// @notice Set to be non executable eternally.
  /// @dev freeza is called by Owner.
  function freeza() public onlyOwner() returns (bool) {
    executable = false;
    cold = true;
    return executable;
  }
}