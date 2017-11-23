pragma solidity ^0.4.18;

/// @title Freezable - Freezable contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract Freezable {

  /**
   * Storage
   */

  address owner;
  bool executable;

  /**
   * Modifier
   */

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  modifier can() {
    require(executable);
    _;
  }

  /**
   * @notice Constructor method
   * @dev Constructor is called when contract deployed.
   */

  function Freezable() public {
    owner = msg.sender;
    executable = true;
  }

  /**
   * functions
   */

  /// @notice freeza execute to initializing registry.
  /// @dev freeza is called by Owner.
  /// @param  _flag    to be stop all executable function when occurring emergency.
  function pause(bool _flag) public onlyOwner() returns (bool) {
    executable = _flag;
    return executable;
  }

  function freeza() public onlyOwner() returns (bool) {
    executable = false;
    return executable;
  }
}