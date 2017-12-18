pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract KaitsukePoD is PoD {

  uint256 public lockTime;
  address public buyer;
  uint256 public tokenMultiplier;
  uint256 public endTime;
  uint256 public totalReceivedWei;

  function KaitsukePoD() public {
    name = "KaitsukePoD strategy token price = capToken/capWei";
    version = "0.1";
    podType = 110;
    lockTime = 30 days;
  }

  function setConfig(uint8 _tokenDecimals, uint256 _capOfToken, uint256 _capOfWei, address _buyer) public onlyOwner() returns (bool) {
    require(status == Status.PoDDeployed);
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;
    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;
    buyer = _buyer;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    
    require(msg.sender == buyer);
    
    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    owner.transfer(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }


  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp < startTime.add(lockTime))
      return 0;
    
    return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;

  }
}
