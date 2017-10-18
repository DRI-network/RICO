pragma solidity ^0.4.15;
import "./RICOToken.sol";
import "./SafeMath.sol";
import "./DutchAuction.sol";

/// @title RICO - Responsible Initial Coin Offering
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICO {
  /// using safemath
  using SafeMath for uint256;

  /**
   * Events 
   */

  event AddTokenRound(uint256 supply, uint256 execTime, address to, uint256 totalReserve);
  event AddWithdrawalRound(uint256 amount, uint256 execTime, address to, uint256 totalWithdrawals);
  event AddMarketMaker(uint256 distributeWei, uint256 execTime, address maker, bytes32 metaData, uint256 totalReserve);
  event Deposit(address sender, uint256 amount);
  event InitTokenData(string name, string symbol, uint8 decimals);
  event InitStructure(uint256 totalSupply, address po, uint256 tobAmountWei, uint256 tobAmountToken);
  event InitDutchAuction(address wallet, uint tokenSupply, uint donating);

  /**
   * Modifiers
   */

  modifier onlyOwner() {
    require(msg.sender == owner);
    // Only owner is allowed to proceed
    _;
  }

  modifier onlyProjectOwner() {
    require(msg.sender == ts.po);
    // Only projectOwner is allowed to proceed
    _;
  }

  modifier isAuctionStage() {
    if (ts.proofOfDonationStrategy == 1) {
      if (auction.stage() == DutchAuction.Stages.AuctionSetUp)
        auction.startAuction();
      if (auction.stage() == DutchAuction.Stages.AuctionEnded)
        status = Status.TokenAuctionEnded;
    }
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
  }

  struct MarketMaker {
    uint256 distributeWei;
    uint256 execTime;
    address maker;
    bytes32 metaData; // meta data is payload to verify identity for marketmaker :) let's marketmaking!!
  }

  struct TokenStructure {
    uint256 totalSupply;
    uint256 tobAmountToken;
    uint256 tobAmountWei;
    uint256 proofOfDonationCapOfWei;
    uint256 proofOfDonationCapOfToken;
    uint256 proofOfDonationStrategy;
    address po;
  }

  enum Status {
    TokenInit,
    TokenCreated,
    TokenStructureConfirmed,
    TokenTobExecuted,
    TokenAuctionEnded
  }

  address public owner;
  uint256 public startTimeOfPoD;
  uint256 public donatedWei;
  uint256 public sendWei;
  uint256 public tokenPrice;
  TokenStructure public ts;
  RICOToken public token;
  DutchAuction public auction;
  mapping(address => uint256) weiBalances;

  Status public status = Status.TokenInit;
  TokenRound[] public tRounds;
  WithdrawalRound[] public wRounds;
  MarketMaker[] public mms;


  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function RICO() {
    owner = msg.sender;
  }

  /**
   * @dev initialize token structure for new project.
   * @param _totalSupply                total supply of Token.
   * @param _tobAmountToken             allocation tob Supply of token total supplies.
   * @param _tobAmountWei               buying amount of project owner when tob call.
   * @param _proofOfDonationCapOfToken  donation cap of token.
   * @param _proofOfDonationCapOfWei    donation cap of ether.
   * @param _proofOfDonationStrategy    donation strategy 0=Normal,1=DutchAuction.
   * @param _po                         project owner address.
   */
  function init(
    address _tokenAddr,
    uint256 _totalSupply,
    uint256 _tobAmountToken,
    uint256 _tobAmountWei,
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei,
    uint256 _proofOfDonationStrategy,
    address _po
  )
  external onlyOwner() returns(bool) 
  {

    require(status == Status.TokenInit);

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
    
    if (_tokenAddr != 0x0)
      token = new RICOToken();
    else
      token = RICOToken(_tokenAddr);

    //set stopPriceFactor 7500
    if (ts.proofOfDonationStrategy == 1) {

      auction = new DutchAuction(ts.po, ts.proofOfDonationCapOfWei, ts.proofOfDonationCapOfToken, 7500);
      //auction contract deployed.
      InitDutchAuction(auction.wallet(), auction.tokenSupply(), auction.donating());
    }

    InitStructure(ts.totalSupply, ts.po, ts.tobAmountWei, ts.tobAmountToken);

    status = Status.TokenCreated;

    return true;
  }

  /**
   * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         representation of Token name.
   * @param _symbol       representation of Token symbol.
   * @param _decimals     representation of Token decimals.
   */
  function initTokenData(string _name, string _symbol, uint8 _decimals) external onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    token.init(_name, _symbol, _decimals);

    InitTokenData(_name, _symbol, _decimals);

    return true;
  }

  /**
   * @dev define a token supply by token creation strategy.
   * @param _roundSupply      represent a token mintable amount for this round.
   * @param _execTime         represent a unlocking time and token creation time.
   * @param _to               represent a token receive address.
   */

  function addTokenRound(uint256 _roundSupply, uint256 _execTime, address _to) external onlyOwner() returns(bool) {

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
   * @param _distributeWei      represent a distribute ether amount for this project.
   * @param _execTime           represent a unlocking distribute time.
   * @param _to                 represent a ether receive address.
   */

  function addWithdrawalRound(uint256 _distributeWei, uint256 _execTime, address _to) external onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(block.timestamp <= _execTime);

    require(calcTotalWithdrawalWei().add(_distributeWei) <= ts.proofOfDonationCapOfWei);

    WithdrawalRound memory wr = WithdrawalRound({
      distributeWei: _distributeWei,
      execTime: _execTime,
      to: _to
    });

    wRounds.push(wr);

    AddWithdrawalRound(wr.distributeWei, wr.execTime, wr.to, calcTotalWithdrawalWei());

    return true;
  }


  /**
   * @dev distribute a tobAmount from project owner defined by token creation strategy.
   * @param _distributeWei      represent a distribute ether amount for this project.
   * @param _execTime           represent a unlocking distribute time.
   * @param _maker              represent a ether receive address.
   * @param _metaData           represent a market maker name or meta payload;
   */

  function addMarketMaker(uint256 _distributeWei, uint256 _execTime, address _maker, bytes32 _metaData) external onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(_execTime >= block.timestamp);

    require(calcTotalDistributeWei().add(_distributeWei) <= ts.tobAmountWei);

    MarketMaker memory mm = MarketMaker({
      distributeWei: _distributeWei,
      execTime: _execTime,
      maker: _maker,
      metaData: _metaData
    });

    mms.push(mm);

    AddMarketMaker(mm.distributeWei, mm.execTime, mm.maker, mm.metaData, calcTotalDistributeWei());

    return true;
  }



  /**
   * @dev confirm token creation strategy by projectOwner.
   */

  function strategyConfirm() external onlyProjectOwner() returns(bool) {

    require(status == Status.TokenCreated);

    if (ts.proofOfDonationStrategy == 1)
      require(auction.stage() == DutchAuction.Stages.AuctionDeployed);

    status = Status.TokenStructureConfirmed;

    return true;

  }


  /**
   * @dev executes ether deposit to tob for project owner.
   */

  function deposit() payable onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(msg.value > 0);

    weiBalances[msg.sender] = weiBalances[msg.sender].add(msg.value);

    Deposit(msg.sender, getBalanceOfWei(msg.sender));

    return true;

  }

  function getBalanceOfWei(address _sender) constant returns(uint256) {
    return weiBalances[_sender];
  }

  /**
   * @dev widthdraw ether from this contract.
   */

  function widthdraw(uint256 _amount) returns (bool) {

    require(weiBalances[msg.sender] >= _amount);

    require(this.balance >= _amount);

    require(msg.sender.send(_amount));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(_amount);

    return true;
  }

  /**
   * @dev executes TOB call from peoject owner.
   * @param _startTimeOfPoD represent a unix time of PoD start.
   */

  function execTOB(uint256 _startTimeOfPoD) external onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(weiBalances[msg.sender] >= ts.tobAmountWei);

    require(token.mintable(ts.po, ts.tobAmountToken, now + 180 days));

    uint256 refunds = weiBalances[msg.sender].sub(ts.tobAmountWei);

    require(msg.sender.send(refunds));

    weiBalances[msg.sender] = 0;

    startTimeOfPoD = _startTimeOfPoD;

    if (ts.proofOfDonationStrategy == 0)
      donatedWei = 0;

    if (ts.proofOfDonationStrategy == 1) {

      token.mintable(address(auction), ts.proofOfDonationCapOfToken, now);

      token.mint(address(auction));

      auction.setup(token);
    }

    status = Status.TokenTobExecuted;

    return true;

  }

  /**
   * @dev executes donate to project and call dutch auction process.
   */

  function donate() payable isAuctionStage() returns(bool) {

    require(status == Status.TokenTobExecuted);

    require(block.timestamp >= startTimeOfPoD);

    if (ts.proofOfDonationStrategy == 0) {

      tokenPrice = ts.proofOfDonationCapOfToken / ts.proofOfDonationCapOfWei;

      uint256 mintable = tokenPrice * msg.value;

      require(donatedWei.add(mintable) <= ts.proofOfDonationCapOfToken);

      require(token.mintable(this, mintable, startTimeOfPoD + 7 days));

      donatedWei = donatedWei.add(mintable);
    }

    if (ts.proofOfDonationStrategy == 1)
      auction.bid.value(msg.value)(msg.sender);

    return true;

  }

  /**
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken() returns(bool) {
    if (ts.proofOfDonationStrategy == 0) // strategy is normal
      token.mint(msg.sender);

    if (ts.proofOfDonationStrategy == 1) // strategy is dutchauction
      auction.claimTokens(msg.sender);

    return true;

  }


  /**
   * @dev executes donate to project and call dutch auction process.
   */

  function execTokenRound(uint256 _index) external returns(bool) {

    require(_index < tRounds.length);

    TokenRound memory tr = tRounds[_index];

    require(block.timestamp >= tr.execTime);

    require(token.totalSupply() <= ts.totalSupply);

    require(token.mintable(tr.to, tr.roundSupply, now));

    require(token.mint(tr.to));

    delete tRounds[_index];

    return true;
  }

  /**
   * @dev executes distribute to market maker follow this token strategy.
   */

  function execWithdrawalRound(uint256 _index) external returns(bool) {

    require(_index < wRounds.length);

    WithdrawalRound memory wr = wRounds[_index];

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
   * @dev executes distribute to market maker follow this token strategy.
   */

  function execMarketMaker(uint256 _index) external onlyProjectOwner() returns(bool) {

    require(_index < mms.length);

    MarketMaker memory mm = mms[_index];

    require(block.timestamp >= mm.execTime);

    require(this.balance >= mm.distributeWei);

    require(mm.maker.send(mm.distributeWei));

    delete mms[_index];

    return true;

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
   * @dev calculate TotalDistributeWei sum of all market makers.
   */

  function calcTotalDistributeWei() internal constant returns(uint256) {

    uint256 totalDistributeWei = 0;

    for (uint i = 0; i < mms.length; i++) {

      MarketMaker memory mm = mms[i];

      totalDistributeWei = totalDistributeWei.add(mm.distributeWei);

    }
    return totalDistributeWei;
  }

  /**
   * @dev calculate total withdrawal ether sum of all rounds.
   */

  function calcTotalWithdrawalWei() internal constant returns(uint256) {

    uint256 totalWithdrawalWei = 0;

    for (uint i = 0; i < wRounds.length; i++) {

      WithdrawalRound memory wr = wRounds[i];

      totalWithdrawalWei = totalWithdrawalWei.add(wr.distributeWei);

    }
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

  function () {
    if (status == Status.TokenStructureConfirmed)
      deposit();
    if (status == Status.TokenTobExecuted)
      donate();
    if (status == Status.TokenAuctionEnded)
      mintToken();
  }


}