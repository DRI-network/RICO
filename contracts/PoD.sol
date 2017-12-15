pragma solidity ^0.4.18;
import "./Ownable.sol";
import "./SafeMath.sol";

/// @title PoD - PoD Strategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract PoD is Ownable {
  using SafeMath for uint256;

  /**
   * Storage
   */

  string  public name;
  uint    public podType;
  string  public version;
  uint256 public period;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public tokenPrice;
  uint256 public totalReceivedWei;
  uint256 public proofOfDonationCapOfToken;
  uint256 public proofOfDonationCapOfWei;
  mapping (address => uint256) weiBalances;

  enum Status {
    PoDDeployed,
    PoDStarted,
    PoDEnded
  }
  Status public status;

  /** 
   * event
   */
  
  event Donated(address user, uint256 amount);
  event Started(uint256 time);
  event Ended(uint256 time);


  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
  }

  function init(uint256 _startTimeOfPoD) public onlyOwner() returns (bool) {
    require(status == Status.PoDDeployed);
    startTime = _startTimeOfPoD;
    totalReceivedWei = 0;
    status = Status.PoDStarted;
    Started(startTime);
    return true;
  }

  function donate() payable public returns (bool) {

    require(status == Status.PoDStarted);

    require(block.timestamp >= startTime);

    require(tx.gasprice <= 80000000000);

    if (!processDonate(msg.sender)) {
      endTime = now;
      status = Status.PoDEnded;
      Ended(endTime);
    } 

    totalReceivedWei = totalReceivedWei.add(msg.value);
    
    if (msg.value > 0)
      owner.transfer(msg.value);

    Donated(msg.sender, msg.value);
    return true;
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;

  }

  function getBalanceOfWei(address _user) public constant returns(uint) {
    return weiBalances[_user];
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

  function isPoDStarted() public constant returns (bool) {
    if (status == Status.PoDStarted)
      return true;
    return false;
  }


  function () payable public {
    donate();
  }

  //Interface functions 

  function processDonate(address _user) internal returns (bool);

  function getBalanceOfToken(address _user) public constant returns (uint256);
}