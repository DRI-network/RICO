pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title RICOStandardPoD - RICOStandardPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICOStandardPoD is PoD {

  address public buyer;
  address[] public marketMakers;
  uint256 public tokenMultiplier;
  uint256 public secondCapOfToken;

  function RICOStandardPoD() public {
    name = "StandardPoD strategy tokenPrice = capToken/capWei";
    version = "0.9.3";
  }

  function init(
    uint8 _tokenDecimals, 
    uint256 _startTimeOfPoD,
    uint256 _capOfToken, 
    uint256 _capOfWei, 
    address[2] _owners,
    address[] _marketMakers,
    uint256 _secondCapOfToken
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);

    require(_startTimeOfPoD >= block.timestamp);
   
    startTime = _startTimeOfPoD;
  
    wallet = this;

    marketMakers = _marketMakers;

    tokenMultiplier = 10 ** uint256(_tokenDecimals);

    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;

    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;

    buyer = _owners[0];
    weiBalances[_owners[1]] = 1;

    secondCapOfToken = _secondCapOfToken;

    status = Status.PoDStarted;
    
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    
    require(msg.sender == buyer);
    
    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }

  function distributeWei(uint _index, uint256 _amount) public returns (bool) {

    require(msg.sender == buyer);

    require(_amount <= this.balance);

    marketMakers[_index].transfer(_amount);

    return true;
  }


  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp < startTime.add(180 days))
      return 0;

    if (_user == buyer)
      return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
    else 
      return secondCapOfToken * weiBalances[_user];
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;

  }
}
