pragma solidity ^0.4.18;
import "./Ownable.sol";
import "./SafeMath.sol";

/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract PoD is Ownable {
  using SafeMath for uint256;

  /**
   * Storage
   */

  string public name;
  string public version;
  address public wallet;
  uint256 public period;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public tokenPrice;
  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;
  uint256 totalReceivedWei;
  mapping (address => uint256) weiBalances;

  enum Status {
    PoDDeployed,
    PoDInitialized,
    PoDStarted,
    PoDEnded
  }
  Status public status;

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
  }

  function init(
    address _wallet,
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei
  )
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    wallet = _wallet;
    proofOfDonationCapOfToken = _proofOfDonationCapOfToken;
    proofOfDonationCapOfWei = _proofOfDonationCapOfWei;
    status = Status.PoDInitialized;
    totalReceivedWei = 0;
    return true;
  }

  function start(uint256 _startTimeOfPoD) public onlyOwner() returns (bool) {
    require(status == Status.PoDInitialized);
    startTime = _startTimeOfPoD;
    status = Status.PoDStarted;
    return true;
  }

  function donate() payable public returns (bool) {

    require(status == Status.PoDStarted);

    require(block.timestamp > startTime);

    require(tx.gasprice <= 50000000000);

    if (processDonate(msg.sender)) {
      totalReceivedWei = totalReceivedWei.add(msg.value);
      require(wallet.send(msg.value));
    }else {
      require(msg.sender.send(msg.value));
      endTime = now;
      status = Status.PoDEnded;
    }
    return true;
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;

  }


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

  //inherit functions 

  function processDonate(address _user) internal returns (bool);

  function getBalanceOfToken(address _user) public constant returns (uint256);
}