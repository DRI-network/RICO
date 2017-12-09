pragma solidity ^0.4.18;
import "./AbsRICOToken.sol";
import "./PoD.sol";

/// @title RICO - Responsible Initial Coin Offering
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICO is Ownable {
  /// using safemath
  using SafeMath for uint256;
  /**
   * Events 
   */

  event InitStructure(uint256 totalSupply, address po, uint256 tobAmountWei, uint256 tobAmountToken);
  event InitTokenData(string name, string symbol, uint8 decimals);
  event AddTokenRound(address pod);
  event AddWithdrawalRound(uint256 amount, uint256 execTime, address to, bool isMM, uint256 totalWithdrawals);
  event Deposit(address sender, uint256 amount);
  event Withdrawal(address receiver, uint256 amount);

  /**
   * Modifiers
   */

  modifier onlyProjectOwner() {
    require(msg.sender == po);
    // Only projectOwner is allowed to proceed
    _;
  }

  /**
   * Storage
   */

  enum Status {
    Deployed,
    Initialized,
    TokenCreated,
    TokenStructureConfirmed,
    RICOStarted,
    RICOEnded
  }

  address public po;
  uint256 public totalSupply;
  uint256 public tobLimitWei;
  uint256 public nowReserveWei;
  uint256 public nowSupply;
  Status public status;
  AbsRICOToken public token;
  address[] public pods;
  mapping(address => mapping(uint256 => uint256)) wLimitWei;

  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function RICO() public {
    status = Status.Deployed;
  }

  /**
   * @dev initialize token structure for new project.
   * @param _tokenAddr                  RICOToken contract's address.
   * @param _totalSupply                total supply of Token.
   * @param _pods                       array of Pod's addresses
   * @param _po                         project owner address.
   */
  function init(
    address _tokenAddr,
    uint256 _totalSupply,
    address[] _pods,
    address _po
  )
  external onlyOwner() returns(bool) 
  {
    require(status == Status.Deployed);

    require(_tokenAddr != 0x0 && _totalSupply > 0 && _po != 0x0);

    token = AbsRICOToken(_tokenAddr);

    totalSupply = _totalSupply;

    nowSupply = 0;

    tobLimitWei = 0;

    nowReserveWei = 0;
     
    po = _po;
    
    pods = _pods;

    status = Status.Initialized;

    return true;
  }

  /**
   * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name of RICO format.
   * @param _symbol       set Token symbol of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   */
  function initTokenData(string _name, string _symbol, uint8 _decimals) public onlyOwner() returns(bool) {

    require(status == Status.Initialized);

    token.init(_name, _symbol, _decimals);

    InitTokenData(_name, _symbol, _decimals);

    status = Status.TokenCreated;

    return true;
  }

  /**
   * @dev define a token supply by token creation strategy.
   * @param _index      check the one address index of array of pods.
   */

  function addTokenRound(uint _index) public onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    PoD pod = PoD(pods[_index]);

    if (pod.podType() == 110)   //TOB pod
      tobLimitWei = tobLimitWei.add(pod.proofOfDonationCapOfWei());
      
    pod.init();

    nowSupply = nowSupply.add(pod.proofOfDonationCapOfToken());

    require(nowSupply <= totalSupply);

    AddTokenRound(address(pod));

    return true;
  }

  /**
   * @dev distribute ether from contract defined by token creation strategy.
   * @param _distributeWei      set distribute ether amount for this project.
   * @param _execTime           set unlocking distribute time.
   * @param _to                 set ether receive address.
   * @param _isMM               set bool for marketmaker flag.
   */

  function addWithdrawalRound(uint256 _distributeWei, uint256 _execTime, address _to, bool _isMM) public onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(_execTime >= block.timestamp);  

    require(wLimitWei[_to][_distributeWei] == 0);  

    if (_isMM)
      require(tobLimitWei >= nowReserveWei.add(_distributeWei));

    wLimitWei[_to][_distributeWei] = _execTime;

    nowReserveWei = nowReserveWei.add(_distributeWei);

    AddWithdrawalRound(_distributeWei, _execTime, _to, _isMM, nowReserveWei);

    return true;
  }

  /**
   * @dev confirm token creation strategy by projectOwner.
   */

  function strategyConfirm(uint _tob) public onlyProjectOwner() returns(bool) {

    require(status == Status.TokenCreated);

    PoD tob = PoD(pods[_tob]);

    require(tob.podType() == 110);   //TOB pod

    tob.start(now);

    status = Status.TokenStructureConfirmed;

    return true;

  }
  
  /**
   * @dev withdraw ether from this contract.
   */

  function withdraw(uint256 _amount) public returns (bool) {

    require(wLimitWei[msg.sender][_amount] > block.timestamp);

    uint256 amount = 0;
    if (_amount >= this.balance) {
      amount = this.balance;
    } else {
      amount = _amount;
    }

    require(msg.sender.send(amount));

    wLimitWei[msg.sender][_amount] = 0;

    Withdrawal(msg.sender, amount);

    return true;
  }

  /**
   * @dev executes TOB call from project owner.
   * @param _startTimeOfPoD represent a unix time of PoD start.
   */

  function execTOB(uint _podToB, uint _podPoD, uint256 _startTimeOfPoD) public onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    PoD tob = PoD(pods[_podToB]);

    require(tob.podType() == 110);   //TOB pod

    require(tob.isPoDEnded());

    PoD pod = PoD(pods[_podPoD]);

    require(pod.start(_startTimeOfPoD));

    status = Status.RICOStarted;

    return true;

  }

  /**
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken(uint _index, address _user) public returns(bool) {

    PoD pod = PoD(pods[_index]);

    require(pod.isPoDEnded());

    uint256 tokenValue = pod.getBalanceOfToken(_user);

    require(tokenValue > 0);

    require(token.mintable(_user, tokenValue, now));

    require(token.mint(_user));

    require(pod.resetWeiBalance(_user));

    status = Status.RICOEnded;
    return true;
  }

  /**
   * @dev automatically execute received transactions.
   */
  function () public {
    mintToken(1, msg.sender);
  }
}