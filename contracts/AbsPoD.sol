pragma solidity ^0.4.18;

/// @title AbsPoD - Abstract PoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsPoD {

  function init(uint256 _proofOfDonationCapOfToken, uint256 _proofOfDonationCapOfWei) public returns(bool);

  function start(uint256 _startTimeOfPoD) public returns(bool);

  function donate() payable public returns(bool);

  function resetTokenBalance(address _user) public returns(bool);

  function getTokenPrice() public constant returns(uint256);

  function getEndtime() public constant returns(uint256);

  function getBalanceOfToken(address _user) public constant returns(uint256);

  function transferOwnership(address newOwner) public;

  function isPoDEnded() public constant returns(bool);
}