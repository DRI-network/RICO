pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract KaitsukePoD is PoD {

  uint256 public lockTime;

  function KaitsukePoD() public {
    name = "KaitsukePoD strategy token price = capToken/capWei";
    version = "0.1";
    podType = 110;
    lockTime = 180 days;
  }

  function setConfig(uint256 _capOfToken, uint256 _capOfWei) public onlyOwner() returns (bool) {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {

    tokenPrice = proofOfDonationCapOfToken / proofOfDonationCapOfWei;

    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);

    tokenPrice = proofOfDonationCapOfToken / proofOfDonationCapOfWei;
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }


  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp < startTime.add(lockTime))
      return 0;
    
    return weiBalances[_user].div(tokenPrice);
  }
}
