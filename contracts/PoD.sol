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
  address public wallet;

  uint256 startTime;
  uint256 endTime;
  uint256 tokenPrice;
  uint256 totalReceivedWei;
  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;
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
  event Initialized(address wallet);
  event Started(uint256 time);
  event Ended(uint256 time);


  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
  }

  function init(address _wallet, uint256 _startTimeOfPoD) public onlyOwner() returns (bool) {
    require(status == Status.PoDDeployed);
    require(_wallet != 0x0);
    startTime = _startTimeOfPoD;
    status = Status.PoDStarted;
    wallet = _wallet;
    totalReceivedWei = 0;
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
      wallet.transfer(msg.value);

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

  function getCapOfToken() public constant returns(uint256) {
    return proofOfDonationCapOfToken;
  }

  function getCapOfWei() public constant returns(uint256) {
    return proofOfDonationCapOfWei;
  }

  function getStartTime() public constant returns (uint256) {
    return startTime;
  }

  function getEndTime() public constant returns (uint256) {
    return endTime;
  }

  function isPoDEnded() public constant returns(bool) {
    if (status == Status.PoDEnded)
      return true;
    return false;
  }

  function isPoDStarted() public constant returns(bool) {
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