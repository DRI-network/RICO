pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title SimplePoD - SimplePoD contract
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

    if (totalReceivedWei.add(msg.value) > proofOfDonationCapOfWei) {
      status = Status.PoDEnded;
      return false;
    }

    tokenPrice = proofOfDonationCapOfToken / proofOfDonationCapOfWei;

    uint256 tokenValue = tokenPrice.mul(msg.value);

    tokenBalances[_user] = tokenBalances[_user].add(tokenValue);

    return true;
  }

  function () payable public {
    donate();
  }
}
