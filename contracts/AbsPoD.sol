pragma solidity ^0.4.18;

/// @title AbsPoD - Abstract PoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

contract AbsPoD {

  function resetWeiBalance(address _user) public returns(bool);

  function getBalanceOfToken(address _user) public constant returns(uint256);

  function getCapOfToken() public constant returns(uint256);

  function isPoDStarted() public constant returns(bool);

  function isPoDEnded() public constant returns(bool);

  function getTokenPrice() public constant returns(uint256);

  function getStartTime() public constant returns (uint256);

  function getEndtime() public constant returns(uint256);

}
