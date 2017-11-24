pragma solidity ^0.4.18;
import "./Ownable.sol";
/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract PoD is Ownable {

  /**
   * Storage
   */

  string name;
  address owner;
  uint256 version;
  uint256 term;
  uint256 startTime;
  uint256 endTime;
  uint256 tokenPrice;
  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;
  mapping (address => uint256) tokenBalances;

  enum Status {
    PoDDeployed,
    PoDInitialized,
    PoDStarted,
    PoDEnded
  }
  Status status;

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
  }

  function init(
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei
  )
  public onlyOwner() returns(bool) 
  {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _proofOfDonationCapOfToken;
    proofOfDonationCapOfWei = _proofOfDonationCapOfWei;
    status = Status.PoDInitialized;
    return true;
  }

  function start(uint256 _startTimeOfPoD) public onlyOwner() returns (bool) {
    require(status == Status.PoDInitialized);
    startTime = _startTimeOfPoD;
    status = Status.PoDStarted;
  }

  function donate() payable public returns (bool) {

    require(status == Status.PoDStarted);

    require(block.timestamp > startTime);

    require(tx.gasprice <= 50000000000);

    if (block.timestamp > startTime + term) {
      status = Status.PoDEnded;
      endTime = now;
      require(msg.sender.send(msg.value));
      return true;
    }
    require(processDonate(msg.sender));

    require(owner.send(msg.value));

    return true;
  }

  function resetTokenBalance(address _user) public onlyOwner() returns (bool) {

    tokenBalances[_user] = 0;

    return true;

  }

  function processDonate(address _user) internal returns (bool);

  function getTokenPrice() public constant returns(uint256) {
    return tokenPrice;
  }

  function getEndtime() public constant returns (uint256) {
    return endTime;
  }

  function isPoDEnded() public constant returns(bool) {

    if (status == Status.PoDEnded)
      return true;

    return false;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    return tokenBalances[_user];
  }
}