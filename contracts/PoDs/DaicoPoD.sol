pragma solidity ^0.4.18;
import "../PoD.sol";
import "../EIP20StandardToken.sol";

/// @title DaicoPoD - DaicoPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract DaicoPoD is PoD {

  // The tap is withdrawal limit (wei / sec) of founder's multisig wallet.
  uint256 public tap;
  // Latest withdrawal time.
  uint256 public lastWithdrawn;
  // Locked token balances of users.
  mapping(address => uint256) lockedTokenBalances; 
  // Contract has total number of all voters.
  uint256 public voterCount;
  // Contract should be called refund funtion if contract is refundable (withdraw mode).
  bool public refundable;
  // EIP20 token that locked to vote.
  EIP20StandardToken public token;
  // Token tokenMultiplier; e.g. 10 ** uint256(18)
  uint256 tokenMultiplier;
  // Flag that whether proposed vote or not.
  bool isProposed;

  // proposal for DAICO proposal
  struct Proposal {
    // Starting vote process at openVoteTime. 
    uint256 openVoteTime;
    // Closing vote process at openVoteTime. 
    uint256 closeVoteTime;
    // Ensure totalVoted Counter in a proposal. 
    uint256 totalVoted;
    // Update tap value if proposal approved.
    uint256 newTap;
    // Represent the flag this proposal contain a Destructor call
    bool isDestruct;
    // Represent a voter's intention counter; e.g. Yes[true] of No[false]
    mapping(bool => uint256) voted;
    // Represent the flag to whether a voter voted or not.
    mapping(address => bool) isVote;
  }
  // Storage of proposals.
  Proposal[] proposals;
    
  /**
   * Events
   */

  event Voted(address _user, bool _flag);
  event DepositToken(address _user, uint256 _amount);
  event WithdrawalToken(address _user, uint256 _amount);
  event SubmittedProposal(uint256 _nextOpenTime, uint256 _nextCloseTime, uint256 _nextTapAmount, bool _isDestruct);
  event ModifiedTap(uint256 _tapAmount);
  event Withdraw(address _user, uint256 _amount, uint256 _time);
  event Refund(address _user, uint256 _amount);


  /**
   * Constructor
   * @dev Set the owner when this contract deployed.
   */
  
  function DaicoPoD() public {
    name = "DaicoPoD strategy token with dao";
    version = "0.9.3";
    tap = 0;
    voterCount = 0;
    refundable = false;
    isProposed = false;
  }


  /**
   * @dev Initialized PoD.
   * @param _wallet            Address of founder's multisig wallet.
   * @param _tokenDecimals     Token decimals for EIP20 token contract.
   * @param _token             Address of EIP20 token contract.
   */
  function init(
    address _wallet, 
    uint8 _tokenDecimals, 
    address _token
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    require(_wallet != 0x0);
    wallet = _wallet;
    startTime = block.timestamp;
    token = EIP20StandardToken(_token);
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    // The first time of contract deployed, contract's token balance should be zero.
    require(token.balanceOf(this) == 0);
    status = Status.PoDStarted;
    return true;
  }

  /**
   * Public fucntions.
   */


  /**
   * @dev Deposit token to this contract for EIP20 token format.
   * And lockedTokenBalances represents amount of deposited token.
   * @param _amount            The Amount of token allowed.
   */
  function depositToken(uint256 _amount) public returns (bool) {

    require(!refundable);

    require(token.transferFrom(msg.sender, this, _amount));

    lockedTokenBalances[msg.sender] = lockedTokenBalances[msg.sender].add(_amount);

    voterCount = voterCount.add(1);

    DepositToken(msg.sender, _amount);

    return true;
  }

  /**
   * @dev Withdraw token from this contract.
   */
  function withdrawalToken() public returns (bool) {
    
    Proposal storage proposal = proposals[proposals.length-1];

    require(!proposal.isVote[msg.sender]);

    uint256 amount = lockedTokenBalances[msg.sender];

    require(amount > 0);

    token.transfer(msg.sender, lockedTokenBalances[msg.sender]);

    voterCount = voterCount.sub(1);

    lockedTokenBalances[msg.sender] = 0;

    WithdrawalToken(msg.sender, amount);
    return true;
  }


  /**
   * @dev Calling vote is available while proposal is opening.
   * @param _flag            The Flag of voter's intention.
   */

  function vote(bool _flag) public returns (bool) {

    Proposal storage proposal = proposals[proposals.length-1];

    require(block.timestamp >= proposal.openVoteTime);
    require(block.timestamp < proposal.closeVoteTime);

    require(!proposal.isVote[msg.sender]);

    require(lockedTokenBalances[msg.sender] >= tokenMultiplier.mul(15000));

    proposal.isVote[msg.sender] = true;
    proposal.voted[_flag] = proposal.voted[_flag].add(1);
    proposal.totalVoted = proposal.totalVoted.add(1);

    Voted(msg.sender, _flag);

    return true;
  }

  /**
   * @dev Submitting proposal to increase tap or destruct funds.
   * @param _nextOpenTime        The open time of next propsoal.
   * @param _nextCloseTime       The close time of next propsoal.
   * @param _nextTapAmount       The newTap num ( wei / sec ).
   * @param _isDestruct          The flag to whether a voter voted or not.
   */

  function submitProposal(uint256 _nextOpenTime, uint256 _nextCloseTime, uint256 _nextTapAmount, bool _isDestruct) public returns (bool) {

    require(block.timestamp >= _nextOpenTime);
    require(_nextCloseTime >= _nextOpenTime.add(7 days));

    require(lockedTokenBalances[msg.sender] >= tokenMultiplier.mul(30000));

    require(tap < _nextTapAmount);

    require(!isProposed);

    Proposal memory newProposal = Proposal({
      openVoteTime: _nextOpenTime,
      closeVoteTime: _nextCloseTime,
      newTap: _nextTapAmount,
      isDestruct: _isDestruct,
      totalVoted: 0
    });

    proposals.push(newProposal);

    isProposed = true;

    SubmittedProposal(_nextOpenTime, _nextCloseTime, _nextTapAmount, _isDestruct);
    return true;
  }

  /**
   * @dev Aggregate the voted results.
   * return uint 0 => No executed, 1 => Modified tap num, 2 => Transition to withdraw mode
   */

  function aggregateVotes() public returns (uint) {
    
    Proposal storage proposal = proposals[proposals.length-1];
    
    require(block.timestamp >= proposal.closeVoteTime);

    require(!refundable);

    uint votedUsers = proposal.voted[true].add(proposal.voted[false]);

    isProposed = false;

    if (votedUsers <= 20) {
      return 0;
    }

    uint absent = voterCount.sub(votedUsers);

    uint threshold = absent.mul(10000).div(6);

    if (proposal.voted[true].mul(10000) > proposal.voted[false].mul(10000).add(threshold)) {
      if (proposal.isDestruct) {
        refundable = true;
        tap = 0;
        return 2;
      } else {
        modifyTap(proposal.newTap);
        return 1;
      }
    }
    return 0;
  }

  /**
   * @dev Founder can withdraw ether from contract.
   * receiver `wallet` whould be called failback function to receiving ether.
   */

  function withdraw() public returns (bool) {

    require(block.timestamp > lastWithdrawn.add(30 days));

    uint256 amount = (block.timestamp - lastWithdrawn) * tap;
    wallet.transfer(amount);

    lastWithdrawn = block.timestamp;
    
    Withdraw(wallet, amount, lastWithdrawn);
    return true;
  }

  /**
   * @dev Founder can decrease the tap amount at anytime.
   * @param _newTap        The new tap quantity.
   */

  function decreaseTap(uint256 _newTap) public returns (bool) {
    // Only called by foudner's multisig wallet.
    require(msg.sender == wallet); 

    require(tap > _newTap);

    modifyTap(_newTap);

    return true;
  }

  /**
   * @dev If contract to be refundable, project supporter can withdraw ether from contract.
   * Basically, supporter gets the amount of ether has dependent by a locked amount of token.
   */

  function refund() public returns (bool) {

    require(refundable);

    uint refundAmount = this.balance * lockedTokenBalances[msg.sender] / token.balanceOf(this);

    require(refundAmount > 0);

    msg.sender.transfer(refundAmount);

    lockedTokenBalances[msg.sender] = 0;
    
    Refund(msg.sender, refundAmount);
    return true;
  }


  /**
   * Private fucntions.
   */


  /**
   * @dev modify tap num. 
   * @param newTap       The withdrawal limit for project owner tap = (wei / sec).
   */

  function modifyTap(uint256 newTap) internal returns (bool) {
    withdraw();
    tap = newTap;
    ModifiedTap(tap);
    return true;
  }

  /**
   * Defined fucntions of RICO's PoD architecture. 
   */

  /**
   * @dev Called by fallback function. (dependent PoD architecture).
   * Assumed that this contract received ether re-directly from other contract based on PoD
   */

  function processDonate(address _user) internal returns (bool) {
    require(_user != 0x0);
    return true;
  }

  
  /**
   * @dev get reserved token balances of _user. inherits PoD architecture. (Not used).
   */
  function getBalanceOfToken(address _user) public constant returns (uint256) {
    require(_user != 0x0);
    return 0;
  }
}
