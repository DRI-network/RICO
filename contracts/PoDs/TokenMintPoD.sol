pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract TokenMintPoD is PoD {

  mapping(address => uint256) tokenBalances; 
  uint256 public time;
  uint256 public proofOfDonationCapOfToken;
  uint256 public proofOfDonationCapOfWei;
  
  function TokenMintPoD() public {
    name = "TokenMintPoD mean that minting Token when elapsed time";
    version = "0.1";
    podType = 111;
  }

  function setConfig(
    address _user, 
    uint256 _amount, 
    uint256 _time,
    uint256 _capOfToken,
    uint256 _capOfWei
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    tokenBalances[_user] = _amount;
    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;
    time = _time;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    assert(_user != 0x0);
    weiBalances[_user] = 1;
    return false;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if ( time > block.timestamp) 
      return 0;
    return weiBalances[_user].mul(tokenBalances[_user]);
  }
}
