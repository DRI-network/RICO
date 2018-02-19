pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title PublicSalePoD - PublicSalePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license - Please check the LICENSE at github.com/DRI-network/RICO

/**
 * @title      TokenMintPoD
 * @dev        Token Mint Proof of Donation
 *             This Contract is used to handle a separate allocation of
 *             tokens outside of the public sale.
 *             Handles minting and locking the separately allocated tokens.
 *             (& Handles all donation functionality from PoD.sol)
 */
contract TokenMintPoD is PoD {

  mapping(address => uint256) tokenBalances; 
  uint256 public lockTime;
  
  function TokenMintPoD() public {
    name = "TokenMintPoD mean that minting Token to user";
    version = "0.9.3";
  }

  /**
   * @dev        initialize PoD contract
   *
   * @param      _user                The address of the user to receive a separate allocation.
   * @param      _allocationOfTokens  Token amount of the separate alloction.
   * @param      _lockTime            Lock time of the allocated tokens.
   *
   * @return     true
   */
  function init(
    address _user, 
    uint256 _allocationOfTokens,
    uint256 _lockTime
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _allocationOfTokens;
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
