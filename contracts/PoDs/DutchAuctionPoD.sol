pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title DutchAuctionPoD - DutchAuction module contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

contract DutchAuctionPoD is PoD {

  /*
   * Storage
   */

  // Starting price in WEI; e.g. 2 * 10 ** 18
  uint256 public priceStart;

  // Divisor constant; e.g. 524880000
  uint256 public priceConstant;
  // Divisor exponent; e.g. 3
  uint32 public priceExponent;
  // Token tokenMultiplier; e.g. 18
  uint256 public tokenMultiplier;

  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;
  /*
   * Modifiers
   */
  modifier atStatus(Status _status) {
    require(status == _status);
    _;
  }

  /*
   * Events
   */

  event Setup(uint indexed _startPrice, uint indexed _priceConstant, uint32 indexed _priceExponent);
  event AuctionStarted(uint indexed _startTime, uint indexed _blockNumber);
  event BidSubmission(address indexed _sender, uint _amount, uint _missingFunds);
  event AuctionEnded(uint _finalPrice);

  /*
   * Public functions
   */

  /// @dev Contract constructor function 
  function DutchAuctionPoD() public { 
    name = "DutchAuction strategy PoD";
    version = "0.9.3";
  }

  function init(
    address _wallet,
    uint8 _tokenDecimals,
    uint256 _startTime,
    uint _priceStart,
    uint _priceConstant,
    uint32 _priceExponent,
    uint256 _capOfToken
  )
  public onlyOwner() atStatus(Status.PoDDeployed) returns(bool)
  {
    require(_tokenDecimals != 0);
    require(_priceStart > 0);
    require(_priceConstant > 0);
    require(_wallet != 0x0);
    wallet = _wallet;
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    startTime = _startTime;
    priceStart = _priceStart;
    priceConstant = _priceConstant;
    priceExponent = _priceExponent;
    proofOfDonationCapOfToken = _capOfToken;
    status = Status.PoDStarted;
    Setup(_priceStart, _priceConstant, _priceExponent);
    
    return true;
  }

  /// --------------------------------- Auction Functions ------------------

  /// @notice Finalize the auction - sets the final Token price and changes the auction
  /// stage after no bids are allowed anymore.
  /// @dev Finalize auction and set the final Token price.
  function finalizeAuction() public atStatus(Status.PoDStarted) {
    // Missing funds should be 0 at this point
    uint missingFunds = missingFundsToEndAuction();
    require(missingFunds == 0);

    // Calculate the final price = WEI / Token
    // Reminder: num_tokens_auctioned is the number of Rei (Token * token_multiplier) that are auctioned
    tokenPrice = tokenMultiplier * totalReceivedWei / proofOfDonationCapOfToken;

    endTime = now;

    AuctionEnded(tokenPrice);

    status = Status.PoDEnded;

    assert(tokenPrice > 0);
  }



  /// @notice Get the Token price in WEI during the auction, at the time of
  /// calling this function. Returns `0` if auction has ended.
  /// Returns `price_start` before auction has started.
  /// @dev Calculates the current Token price in WEI.
  /// @return Returns WEI per Token (token_multiplier * Rei).
  function price() public constant returns(uint) {
    if (status == Status.PoDEnded) {
      return 0;
    }
    return calcTokenPrice();
  }

  /// @notice Get the missing funds needed to end the auction,
  /// calculated at the current Token price in WEI.
  /// @dev The missing funds amount necessary to end the auction at the current Token price in WEI.
  /// @return Returns the missing funds amount in WEI.
  function missingFundsToEndAuction() public constant returns(uint) {

    // num_tokens_auctioned = total number of Rei (Token * token_multiplier) that is auctioned
    uint requiredWeiAtPrice = proofOfDonationCapOfToken * price() / tokenMultiplier;
    if (requiredWeiAtPrice <= totalReceivedWei) {
      return 0;
    }

    // assert(required_wei_at_price - received_wei > 0);
    return requiredWeiAtPrice - totalReceivedWei;
  }

  /*
   *  Private functions
   */

  /// @dev Calculates the token price (WEI / Token) at the current timestamp
  /// during the auction; elapsed time = 0 before auction starts.
  /// Based on the provided parameters, the price does not change in the first
  /// `price_constant^(1/price_exponent)` seconds due to rounding.
  /// Rounding in `decay_rate` also produces values that increase instead of decrease
  /// in the beginning; these spikes decrease over time and are noticeable
  /// only in first hours. This should be calculated before usage.
  /// @return Returns the token price - Wei per Token.
  function calcTokenPrice() constant private returns(uint) {
    uint elapsed;
    if (status == Status.PoDStarted) {
      elapsed = now - startTime;
    }

    uint decayRate = elapsed ** priceExponent / priceConstant;
    return priceStart * (1 + elapsed) / (1 + elapsed + decayRate);
  }

  /// Inherited functions


  /// @notice Send `msg.value` WEI to the auction from the `msg.sender` account.
  /// @dev Allows to send a bid to the auction.
  function processDonate(address _user) internal returns (bool) {
    require(_user != 0x0);
    // Missing funds without the current bid value
    uint missingFunds = missingFundsToEndAuction();

    // We require bid values to be less than the funds missing to end the auction
    // at the current price.
    require(msg.value <= missingFunds);

    // distribute ether to wallet.
    wallet.transfer(msg.value);

    // Send bid amount to wallet
    BidSubmission(msg.sender, msg.value, missingFunds);

    //assert(totalReceivedWei >= msg.value);
    return true;
  }

  function getBalanceOfToken(address _user) public constant returns(uint) {
    
    uint num = (tokenMultiplier * weiBalances[_user]) / tokenPrice;
    return num;
  }
}
