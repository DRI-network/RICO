pragma solidity ^0.4.18;

/// @title AbsPoD - Abstract PoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsPoD {

  function resetWeiBalance(address _user) public returns(bool);

  function getBalanceOfToken(address _user) public constant returns(uint256);

  function transferOwnership(address newOwner) public;

  function getCapOfToken() public constant returns(uint256);

  function isPoDStarted() public constant returns(bool);

  function isPoDEnded() public constant returns(bool);

  function getTokenPrice() public constant returns(uint256);

  function getStartTime() public constant returns (uint256);

  function getEndtime() public constant returns(uint256);

}
