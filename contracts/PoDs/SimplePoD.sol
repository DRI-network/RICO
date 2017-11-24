pragma solidity ^0.4.18;
import "../PoD.sol";
import "../SafeMath.sol";

/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract SimplePoD is PoD {
  using SafeMath for uint256;

  function SimplePoD() public {
    name = "SimplePoD strategy token price = capToken/capWei ";
    version = 1;
    term = 7 days;
  }

  function processDonate(address _user) internal returns (bool) {

    tokenPrice = proofOfDonationCapOfToken / proofOfDonationCapOfWei;

    tokenBalances[_user] = tokenBalances[_user].add(tokenPrice * msg.value);

    return true;
  }

  function () payable public {
    donate();
  }
}
