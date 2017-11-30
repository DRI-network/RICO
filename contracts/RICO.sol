pragma solidity ^0.4.18;
import "./RICOToken.sol";
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
  event AddTokenRound(uint256 supply, uint256 execTime, address to, uint256 totalReserve);
  event AddWithdrawalRound(uint256 amount, uint256 execTime, address to, bool isMM, uint256 totalWithdrawals);
  event Deposit(address sender, uint256 amount);
  event Withdrawal(address receiver, uint256 amount);

  /**
   * Modifiers
   */

  modifier onlyProjectOwner() {
    require(msg.sender == ts.po);
    // Only projectOwner is allowed to proceed
    _;
  }

  /**
   * Storage
   */

  struct TokenRound {
    uint256 roundSupply;
    uint256 execTime;
    address to;
  }

  struct WithdrawalRound {
    uint256 distributeWei;
    uint256 execTime;
    address to;
    bool isMarketMaker;
  }

  struct TokenStructure {
    uint256 totalSupply;
    uint256 tobAmountToken;
    uint256 tobAmountWei;
    uint256 proofOfDonationCapOfWei;
    uint256 proofOfDonationCapOfToken;
    address proofOfDonationStrategy;
    address po;
  }

  enum Status {
    Deployed,
    Initialized,
    TokenCreated,
    TokenStructureConfirmed,
    PoDStarted,
    PoDEnded
  }

  Status public status;
  address public owner;
  uint256 public startTimeOfPoD;
  uint256 public donatedWei;
  uint256 public sendWei;
  uint256 public tokenPrice;
  TokenStructure public ts;
  RICOToken public token;
  PoD public pod;
  mapping(address => uint256) weiBalances;

  TokenRound[] public tRounds;
  WithdrawalRound[] public wRounds;


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
   * @param _tobAmountToken             allocation tob Supply of token total supplies.
   * @param _tobAmountWei               buying amount of project owner when tob call.
   * @param _proofOfDonationCapOfToken  donation cap of token.
   * @param _proofOfDonationCapOfWei    donation cap of ether.
   * @param _proofOfDonationStrategy    PoD contract's address.
   * @param _po                         project owner address.
   */
  function init(
    address _tokenAddr,
    uint256 _totalSupply,
    uint256 _tobAmountToken,
    uint256 _tobAmountWei,
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei,
    address _proofOfDonationStrategy,
    address _po
  )
  external onlyOwner() returns(bool) 
  {
    require(status == Status.Deployed);

    ts = TokenStructure({
      totalSupply: _totalSupply,
      tobAmountToken: _tobAmountToken,
      tobAmountWei: _tobAmountWei,
      proofOfDonationCapOfWei: _proofOfDonationCapOfWei,
      proofOfDonationCapOfToken: _proofOfDonationCapOfToken,
      proofOfDonationStrategy: _proofOfDonationStrategy,
      po: _po
    });

    require(_totalSupply >= calcEnsureSupply());

    require(_tokenAddr != 0x0 && _proofOfDonationStrategy != 0x0);
    
    token = RICOToken(_tokenAddr);

    pod = PoD(_proofOfDonationStrategy);

    pod.init(this, ts.proofOfDonationCapOfToken, ts.proofOfDonationCapOfWei);
    
    InitStructure(ts.totalSupply, ts.po, ts.tobAmountWei, ts.tobAmountToken);

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
   * @param _roundSupply      set token mintable amount for this round.
   * @param _execTime         set unlocking time and token creation time.
   * @param _to               set token receive address.
   */

  function addTokenRound(uint256 _roundSupply, uint256 _execTime, address _to) public onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(_execTime >= block.timestamp);

    uint256 mintableOfRound = ts.totalSupply - calcEnsureSupply() - calcTotalReserveSupply();

    require(mintableOfRound >= _roundSupply);

    TokenRound memory tr = TokenRound({
      roundSupply: _roundSupply,
      execTime: _execTime,
      to: _to
    });

    tRounds.push(tr);

    AddTokenRound(tr.roundSupply, tr.execTime, tr.to, calcTotalReserveSupply());

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

    if (_isMM)
      require(calcTotalWithdrawalWei(_isMM).add(_distributeWei) <= ts.tobAmountWei);
    else
      require(calcTotalWithdrawalWei(_isMM).add(_distributeWei) <= ts.proofOfDonationCapOfWei);

    WithdrawalRound memory wr = WithdrawalRound({
      distributeWei: _distributeWei,
      execTime: _execTime,
      to: _to,
      isMarketMaker: _isMM
    });

    wRounds.push(wr);

    AddWithdrawalRound(wr.distributeWei, wr.execTime, wr.to, wr.isMarketMaker, calcTotalWithdrawalWei(_isMM));

    return true;
  }

  /**
   * @dev confirm token creation strategy by projectOwner.
   */

  function strategyConfirm() public onlyProjectOwner() returns(bool) {

    require(status == Status.TokenCreated);

    status = Status.TokenStructureConfirmed;

    return true;

  }


  /**
   * @dev executes ether deposit to tob for project owner.
   */

  function deposit() payable public onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(msg.value > 0);

    weiBalances[msg.sender] = weiBalances[msg.sender].add(msg.value);

    Deposit(msg.sender, getBalanceOfWei(msg.sender));

    return true;

  }

  /**
   * @dev withdraw ether from this contract.
   */

  function withdraw(uint256 _amount) public returns (bool) {

    require(weiBalances[msg.sender] >= _amount);

    require(this.balance >= _amount);

    require(msg.sender.send(_amount));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(_amount);

    Withdrawal(msg.sender, _amount);

    return true;
  }

  /**
   * @dev executes TOB call from project owner.
   * @param _startTimeOfPoD represent a unix time of PoD start.
   */

  function execTOB(uint256 _startTimeOfPoD) public onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(_startTimeOfPoD >= block.timestamp + 1 days);

    require(weiBalances[msg.sender] >= ts.tobAmountWei);

    require(token.mintable(ts.po, ts.tobAmountToken, now + 180 days));

    uint256 refunds = weiBalances[msg.sender].sub(ts.tobAmountWei);

    require(msg.sender.send(refunds));

    require(pod.start(_startTimeOfPoD));

    weiBalances[msg.sender] = 0;

    startTimeOfPoD = _startTimeOfPoD;

    status = Status.PoDStarted;

    return true;

  }

  /**
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken(address _user) public returns(bool) {

    require(pod.isPoDEnded());

    status = Status.PoDEnded;

    require(block.timestamp > pod.getEndtime() + 7 days);

    uint256 tokenValue = pod.getBalanceOfToken(_user);

    require(tokenValue > 0);

    require(token.mintable(_user, tokenValue, now));

    require(token.mint(_user));

    require(pod.resetWeiBalance(_user));

    return true;

  }


  /**
   * @dev executes donate to project and call dutch auction process.
   */

  function execTokenRound(uint256 _index) public returns(bool) {

    require(_index < tRounds.length);

    TokenRound memory tr = tRounds[_index];

    require(block.timestamp >= tr.execTime);

    require(tr.to != 0x0);

    require(token.getTotalSupply() <= ts.totalSupply);

    require(token.mintable(tr.to, tr.roundSupply, now));

    require(token.mint(tr.to));

    delete tRounds[_index];

    return true;
  }

  /**
   * @dev executes distribute to market maker follow this token strategy.
   */

  function execWithdrawalRound(uint256 _index) public returns(bool) {

    require(_index < wRounds.length);

    WithdrawalRound memory wr = wRounds[_index];

    if (wr.isMarketMaker) 
      require(msg.sender == ts.po);    //only call by projectOwner 
    else
      require(msg.sender == wr.to);
    

    require(block.timestamp >= wr.execTime);
   
    uint256 amount = 0;

    if (donatedWei >= sendWei.add(wr.distributeWei)) {
       amount = wr.distributeWei;
    } else {
       amount = donatedWei - sendWei;
    }

    weiBalances[wr.to] = weiBalances[wr.to].add(amount);

    sendWei = sendWei.add(wr.distributeWei);

    delete wRounds[_index];

    return true;

  }

  /**
   * @dev get balance of total withdrawal ether for sender.
   */
  function getBalanceOfWei(address _sender) public constant returns(uint256) {
    return weiBalances[_sender];
  }

  /**
   * @dev calculate TotalReserveSupply sum of all rounds.
   */

  function calcTotalReserveSupply() internal constant returns(uint256) {

    uint256 totalReserveSupply = 0;

    for (uint i = 0; i < tRounds.length; i++) {

      TokenRound memory round = tRounds[i];

      totalReserveSupply = totalReserveSupply.add(round.roundSupply);

    }
    return totalReserveSupply;
  }

  /**
   * @dev calculate total withdrawal ether sum of all rounds.
   */

  function calcTotalWithdrawalWei(bool _isMM) internal constant returns(uint256) {

    uint256 totalWithdrawalWei = 0;
    uint256 totalWithdrawalWeiToMM = 0;

    for (uint i = 0; i < wRounds.length; i++) {

      WithdrawalRound memory wr = wRounds[i];

      if (wr.isMarketMaker)
        totalWithdrawalWeiToMM = totalWithdrawalWei.add(wr.distributeWei);
      else
        totalWithdrawalWei = totalWithdrawalWei.add(wr.distributeWei);

    }
    if (_isMM) 
        return totalWithdrawalWeiToMM;
    return totalWithdrawalWei;
  }

  /**
   * @dev calculate token EnsureSupply sum of all supply before confirm strategy.
   */

  function calcEnsureSupply() internal constant returns(uint256) {
    return ts.tobAmountToken + ts.proofOfDonationCapOfToken;
  }

  /**
   * @dev automatically execute received transactions.
   */
  function () public {
    mintToken(msg.sender);
  }
}