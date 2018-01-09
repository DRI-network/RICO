pragma solidity ^0.4.18;
import "./Ownable.sol";
import "./SafeMath.sol";

/// @title PoD - PoD Based contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract PoD is Ownable {
  using SafeMath for uint256;

  /**
   * Storage
   */
  
  string  public name;
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
  event Ended(uint256 time);


  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function PoD() public {
    status = Status.PoDDeployed;
    totalReceivedWei = 0;
    wallet = msg.sender;
  }

  /**
   * @dev executes donate from project supporter.
   */

  function donate() payable public returns (bool) {

    require(status == Status.PoDStarted);

    require(block.timestamp >= startTime);

    // gasprice limit is set to 80 Gwei.  
    require(tx.gasprice <= 80000000000);

    // call the internal function.
    if (!processDonate(msg.sender)) {
      endTime = now;
      status = Status.PoDEnded;
      Ended(endTime);
    } 

    totalReceivedWei = totalReceivedWei.add(msg.value);
    
    // if contract get some ether, distribute to wallet.
    if (msg.value > 0)
      wallet.transfer(msg.value);

    Donated(msg.sender, msg.value);
    return true;
  }

  /**
   * @dev executes reset user's reserved token .
   * @param _user         set minter's address
   */

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    // reset user's wei balances.
    weiBalances[_user] = 0;

    return true;

  }

  /**
   * @dev To get user's balance of wei.
   */

  function getBalanceOfWei(address _user) public constant returns(uint) {
    return weiBalances[_user];
  }

  /**
   * @dev To get token price.
   */
  function getTokenPrice() public constant returns(uint256) {
    return tokenPrice;
  }

  /**
   * @dev To get maximum token cap of pod.
   */

  function getCapOfToken() public constant returns(uint256) {
    return proofOfDonationCapOfToken;
  }

  /**
   * @dev To get maximum wei cap of pod.
   */
  function getCapOfWei() public constant returns(uint256) {
    return proofOfDonationCapOfWei;
  }

  /**
   * @dev To get maximum wei cap of pod.
   */

  function getStartTime() public constant returns (uint256) {
    return startTime;
  }

  /**
   * @dev To get endTime of pod.
   */
  function getEndTime() public constant returns (uint256) {
    return endTime;
  }

  /**
   * @dev get the status equal started of pod.
   */

  function isPoDStarted() public constant returns(bool) {
    if (status == Status.PoDStarted)
      return true;
    return false;
  }

  /**
   * @dev get the status equal ended of pod.
   */

  function isPoDEnded() public constant returns(bool) {
    if (status == Status.PoDEnded)
      return true;
    return false;
  }

  /**
   * fallback function
   */

  function () payable public {
    donate();
  }

  /**
   * Interface functions. 
   */

  function processDonate(address _user) internal returns (bool);

  function getBalanceOfToken(address _user) public constant returns (uint256);
}