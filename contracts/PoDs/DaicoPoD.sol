pragma solidity ^0.4.18;
import "../PoD.sol";
import "../EIP20StandardToken.sol";

/// @title DaicoPoD - DaicoPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract DaicoPoD is PoD {

  // tap is withdrawal limit (wei / sec)
  uint256 public tap;
  // last time of withdrawal funds.
  uint256 public lastWithdrawn;
  // define Token Deposit and Locked balances.
  mapping(address => uint256) lockedVotePowers; 
  // contract has num of all voters.
  uint256 public voterCount;
  // contract should be called refund funtion if refundable.
  bool public refundable;
  // define EIP20 token that use and locked to vote.
  EIP20StandardToken public token;
  // Token tokenMultiplier; e.g. 10 ** uint256(18)
  uint256 tokenMultiplier;
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
  // storage of proposals.
  Proposal[] proposals;
    
  /**
   * Events
   */

  event Voted(address user, bool flag);

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */
  
  function DaicoPoD() public {
    name = "DaicoPoD strategy token with dao";
    version = "0.9.3";
    tap = 0;
    voterCount = 0;
    refundable = false;
  }


  /**
   * @dev init contract defined params.
   * @param _wallet            Address of ProjectOwner's multisig wallet.
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
   * and deposited token is to be lockedVotePowers.
   * @param _amount            The Amount of token allowed.
   */
  function depositToken(uint256 _amount) public returns (bool) {

    require(!refundable);

    require(token.transferFrom(msg.sender, this, _amount));

    lockedVotePowers[msg.sender] = lockedVotePowers[msg.sender].add(_amount);

    voterCount = voterCount.add(1);

    return true;
  }

  /**
   * @dev withdrawal token from this contract.
   * and `msg.sender` lose all lockedVotePowers if this method has called.
   */
  function withdrawalToken() public returns (bool) {
    
    var proposal = proposals[proposals.length-1];

    require(!proposal.isVote[msg.sender]);

    require(lockedVotePowers[msg.sender] > 0);

    token.transfer(msg.sender, lockedVotePowers[msg.sender]);

    voterCount = voterCount.sub(1);

    lockedVotePowers[msg.sender] = 0;

    return true;
  }


  /**
   * @dev Calling vote is available while proposal is opening.
   * @param _flag            The Flag of voter's intention.
   */

  function vote(bool _flag) public returns (bool) {

    var proposal = proposals[proposals.length-1];

    require(block.timestamp >= proposal.openVoteTime);
    require(block.timestamp < proposal.closeVoteTime);

    require(!proposal.isVote[msg.sender]);

    require(lockedVotePowers[msg.sender] >= tokenMultiplier.mul(15000));

    proposal.isVote[msg.sender] = true;
    proposal.voted[_flag] = proposal.voted[_flag].add(1);
    proposal.totalVoted = proposal.totalVoted.add(1);

    Voted(msg.sender, _flag);
  }

  /**
   * @dev Aggregate the voted results and calling modiryTap process or destruct.
   * @param _nextOpenTime        The open time of next propsoal.
   * @param _nextCloseTime       The close time of next propsoal.
   * @param _nextNewTap              The newTap params.
   * @param _isDestruct          The flag to whether a voter voted or not.
   */

  function aggregate(uint256 _nextOpenTime, uint256 _nextCloseTime, uint256 _nextNewTap, bool _isDestruct) public returns (bool) {

    var proposal = proposals[proposals.length-1];
    
    require(block.timestamp >= proposal.closeVoteTime);
    require(block.timestamp >= _nextOpenTime);
    require(_nextCloseTime >= _nextOpenTime.add(7 days));

    require(!refundable);

    uint votedUsers = proposal.voted[true].add(proposal.voted[false]);

    //require(votedUsers >= 20);

    uint absent = voterCount.sub(votedUsers);

    if (proposal.voted[true] > proposal.voted[false].add(absent.div(6))) {
      if (proposal.isDestruct) {
        refundable = true;
        tap = 0;
      } else {
        modifyTap(proposal.newTap);
      }
    }

    require(tap < _nextNewTap);

    Proposal memory newProposal = Proposal({
      openVoteTime: _nextOpenTime,
      closeVoteTime: _nextCloseTime,
      newTap: _nextNewTap,
      isDestruct: _isDestruct,
      totalVoted: 0
    });

    proposals.push(newProposal);

    return true;
  }

  /**
   * @dev founder can withdrawal ether from contract.
   * receiver `wallet` whould be called failback function to receiving ether.
   */

  function withdraw() public {

    wallet.transfer((block.timestamp - lastWithdrawn) * tap);

    lastWithdrawn = block.timestamp;
  }

  /**
   * @dev founder can withdrawal ether from contract.
   * receiver `wallet` called fallback function to receiving ether.
   */

  function decreaseTap(uint256 _newTap) public returns (bool) {
    // only called by foudner's multisig wallet.
    require(msg.sender == wallet); 

    require(tap > _newTap);

    modifyTap(_newTap);
  }

  /**
   * @dev if contract to be refundable, project supporter can withdrawal ether from contract.
   * basically, supporter gets the amount of ether has dependent by a locked amount of token.
   */

  function refund() public returns (bool) {

    require(refundable);

    uint refundAmount = this.balance * lockedVotePowers[msg.sender] / token.balanceOf(this);

    require(refundAmount > 0);

    msg.sender.transfer(refundAmount);

    lockedVotePowers[msg.sender] = 0;
    
    return true;
  }


  /**
   * @dev modify tap num. 
   * @param newTap       The withdrawal limit for project owner tap = (wei / sec).
   */

  function modifyTap(uint256 newTap) internal returns (bool) {
    withdraw();
    tap = newTap;
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
    return 0;
  }
}
