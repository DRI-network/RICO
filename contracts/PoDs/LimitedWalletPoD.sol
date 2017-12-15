pragma solidity ^0.4.18;
import "../PoD.sol";

/// @title LimitedWalletPoD - LimitedWalletPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract LimitedWalletPoD is PoD {

  mapping(address => mapping(uint256 => uint256)) public wLimitWei;

  function LimitedWalletPoD() public {
    name = "LimitedWalletPoD - the wallet pod with widthdrawalLimit each address.";
    version = "0.1";
    podType = 111;
  }

  function setConfig(
    address[] _users, 
    uint256[] _limitWeis,
    uint256[] _periods
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    for (uint i = 0; i < _users.length - 1; i++) {
      require(block.timestamp <= _periods[i]);
      wLimitWei[_users[i]][_limitWeis[i]] = _periods[i];
    }
    return true;
  }

  function withdraw(address _user, uint256 _amount) public returns (bool) {

    require(wLimitWei[_user][_amount] <= block.timestamp);

    uint256 amount = 0;
    if (this.balance < _amount) {
      amount = this.balance;
    } else {
      amount = _amount;
    }
    require(_user.send(amount));

    wLimitWei[_user][_amount] = 0;

    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    assert(_user != 0x0);
    return true;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    return 0;
  }
}
