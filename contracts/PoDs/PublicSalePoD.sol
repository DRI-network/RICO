pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title PublicSalePoD - PublicSalePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

/**
 * @title      PublicSalePoD
 * @dev        Public Sale Proof of Donation
 *             Handles the donations of the public sale and stores them.
 *             Handles the transfer of funds from the donators to the Project Owner's wallet.
 *             (& Handles all donation functionality from PoD.sol)
 */
contract PublicSalePoD is PoD {

  uint256 public tokenMultiplier;
  uint256 public period;

  function PublicSalePoD() public {
    name = "PublicSalePoD strategy token price = capToken/capWei";
    version = "0.9.3";
  }

  /**
   * @dev        initialize PoD contract
   *
   * @param      _wallet          The owner's wallet to pay donations to
   * @param      _tokenDecimals   The token decimals
   * @param      _startTimeOfPoD  The start time of the public sale
   * @param      _capOfToken      The cap of tokens to be sold during the public sale
   * @param      _capOfWei        The cap of wei for the public sale
   *
   * @return     true
   */
  function init(
    address _wallet, 
    uint8 _tokenDecimals,
    uint256 _startTimeOfPoD,
    uint256 _capOfToken, 
    uint256 _capOfWei
  )
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    require(_wallet != 0x0);
    startTime = _startTimeOfPoD;
    wallet = _wallet;
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;
    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;
    period = 7 days;
    status = Status.PoDStarted;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {

    require(block.timestamp <= startTime.add(period));

    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    wallet.transfer(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }

  /**
   * @dev      finalize() will bring the ICO to a conclusion. Anyone can call this function.
   */
  function finalize() public {

    require(status == Status.PoDStarted);

    require(block.timestamp > startTime.add(period));

    endTime = now;

    status = Status.PoDEnded;

    Ended(endTime);
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
  }
}
