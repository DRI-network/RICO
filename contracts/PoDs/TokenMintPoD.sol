pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract TokenMintPoD is PoD {

  mapping(address => uint256) tokenBalances; 
  uint256 public lockTime;
  
  function TokenMintPoD() public {
    name = "TokenMintPoD mean that minting Token to user";
    version = "0.9.3";
  }

  function init(
    address _user, 
    uint256 _capOfToken,
    uint256 _lockTime
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _capOfToken;
    tokenBalances[_user] = proofOfDonationCapOfToken;
    lockTime = _lockTime;
    weiBalances[_user] = 1;
    status = Status.PoDStarted;
    return true;
  }

  function finalize() public {
    status = Status.PoDEnded;
  }

  function processDonate(address _user) internal returns (bool) {
    require(_user == 0x0);
    return true;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp <= lockTime) 
      return 0;

    return weiBalances[_user].mul(tokenBalances[_user]);
  }
}
