pragma solidity ^0.4.18;

/// @title Dutch auction contract - distribution of a fixed number of tokens using an auction.
/// The contract code is inspired by the Gnosis auction contract. Main difference is that the
/// auction ends if a fixed number of tokens was sold.
/// @notice contract based on Raiden-Project. Thanks to hard commit ethereum-communities!
/// https://github.com/raiden-network/raiden-token/blob/master/contracts/auction.sol
contract AbsDutchAuctionRegistry {
  /// using safemath
  function init( address _wallet, address _caller, uint256 _tokenSupply, uint8 _tokenDecimals) public returns(bool);

  function setup(uint256 _priceStart, uint256 _priceConstant, uint32 _priceExponent) public;

  function startAuction() public;

  function finalizeAuction() public;

  function bid(address _receiver) public payable;

  function claimTokens(address _receiver) public returns(bool);

  function getTokenBalance(address _user) constant public returns(uint);

  function price()  constant public returns(uint);

  function missingFundsToEndAuction() constant public returns(uint);
}