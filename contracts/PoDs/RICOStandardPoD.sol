pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title RICOStandardPoD - RICOStandardPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

/**
 * @title      RICOStandardPoD
 * @dev        RICO Standard Proof of Donation
 *             Handles the Initial Deposit and the functionality to lock up those tokens.
 *             Handles payments to the Market Makers.
 *             (& Handles all donation functionality from PoD.sol)
 */
contract RICOStandardPoD is PoD {

  address public initialDepositFunder;
  address[] public marketMakers;
  uint256 public tokenMultiplier;
  uint256 public secondOwnerAllocation;

  function RICOStandardPoD() public {
    name = "StandardPoD strategy tokenPrice = capToken/capWei";
    version = "0.9.3";
  }

  /**
   * @dev      initialize PoD contract
   *
   * @param    _tokenDecimals           The token decimals
   * @param    _startTime               The start time for the lock period of 180 days of the owner's tokens.
   * @param    _allocationOfTokens      The allocation of tokens for the Initial Deposit
   * @param    _priceInWei              The price of Wei for the Initial Deposit
   * @param    _owners                  array
   *           _owners[0]               Owner & Initial Deposit Funder
   *           _owners[1]               Second owner (can receive secondOwnerAllocation)
   * @param    _marketMakers            array of addresses of the market makers.
   * @param    _secondOwnerAllocation   The allocation of tokens to go to the second owner
   *
   * @return   true
   */
  function init(
    uint8 _tokenDecimals, 
    uint256 _startTime,
    uint256 _allocationOfTokens,
    uint256 _priceInWei,
    address[2] _owners,
    address[] _marketMakers,
    uint256 _secondOwnerAllocation
  ) 
  public onlyOwner() returns (bool) {
    require(status == Status.PoDDeployed);

    require(_startTime >= block.timestamp);
   
    startTime = _startTime;
  
    marketMakers = _marketMakers;

    tokenMultiplier = 10 ** uint256(_tokenDecimals);

    proofOfDonationCapOfToken = _allocationOfTokens;
    proofOfDonationCapOfWei = _priceInWei;

    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;

    initialDepositFunder = _owners[0];
    weiBalances[_owners[1]] = 1; // _owners[1] is the initialDepositLocker.

    secondOwnerAllocation = _secondOwnerAllocation;

    status = Status.PoDStarted;
    
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    require(_user == initialDepositFunder);
    
    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    //distribute ether to wallet.
    //wallet.transfer(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }

  function distributeWei(uint _index, uint256 _amount) public returns (bool) {
    require(msg.sender == initialDepositFunder);

    require(_amount <= this.balance);

    marketMakers[_index].transfer(_amount);

    return true;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp < startTime.add(180 days))
      return 0;

    if (_user == initialDepositFunder)
      return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
    else 
      return secondOwnerAllocation * weiBalances[_user];
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {
    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;
  }
}
