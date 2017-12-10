pragma solidity ^0.4.18;

/// @title AbsRICOToken - abstract contract for RICOToken
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsRICOToken {
  function init(string _name, string _symbol, uint8 _decimals) public returns(bool);
  function mintable(address _user, uint256 _amount, uint256 _atTime) public returns(bool);
  function mint(address _user) public returns(bool);
  function transferOwnership(address newOwner) public;
  function getTotalSupply() public returns(uint256);
}