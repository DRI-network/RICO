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
  bool cold;

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