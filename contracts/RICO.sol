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
    if (auction.stage() == DutchAuction.Stages.AuctionSetUp)
      auction.startAuction();
    if (auction.stage() == DutchAuction.Stages.AuctionEnded)
      status = Status.TokenAuctionEnded;
    _;
  }

  /**
   * Storage
   */

  struct Round {
    uint256 roundSupply;
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
  uint256 public startAuctionTime;
  TokenStructure public ts;
  RICOToken public token;
  DutchAuction public auction;
  mapping(address => uint256) weiBalances;

  Status public status = Status.TokenInit;
  Round[] public rounds;
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
   * @param _po                         project owner address.
   */
  function init(
    uint256 _totalSupply,
    uint256 _tobAmountToken,
    uint256 _tobAmountWei,
    uint256 _proofOfDonationCapOfToken,
    uint256 _proofOfDonationCapOfWei,
    address _po
  )
  internal onlyOwner() returns(bool) 
  {

    require(status == Status.TokenInit);

    ts = TokenStructure({
      totalSupply: _totalSupply,
      tobAmountToken: _tobAmountToken,
      tobAmountWei: _tobAmountWei,
      proofOfDonationCapOfWei: _proofOfDonationCapOfWei,
      proofOfDonationCapOfToken: _proofOfDonationCapOfToken,
      po: _po
    });

    require(_totalSupply >= calcEnsureSupply());

    token = new RICOToken();

    //set stopPriceFactor 8000
    auction = new DutchAuction(ts.po, ts.proofOfDonationCapOfWei, ts.proofOfDonationCapOfToken, 8000); 
    //auction contract deployed.

    InitDutchAuction(auction.wallet(), auction.tokenSupply(), auction.donating());

    InitStructure(ts.totalSupply, ts.po, ts.tobAmountWei, ts.tobAmountToken);

    status = Status.TokenCreated;

    return true;
  }

  /**
   * @dev initialize token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         represent a Token name.
   * @param _symbol       represent a Token symbol.
   * @param _decimals     represent a Token decimals.
   */
  function initTokenData(string _name, string _symbol, uint8 _decimals) internal onlyOwner() returns(bool) {

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

  function addTokenRound(uint256 _roundSupply, uint256 _execTime, address _to) internal onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(_execTime >= block.timestamp);

    uint256 mintableOfRound = ts.totalSupply - calcEnsureSupply() - calcTotalReserveSupply();

    require(mintableOfRound >= _roundSupply);

    Round memory round = Round({
      roundSupply: _roundSupply,
      execTime: _execTime,
      to: _to
    });

    rounds.push(round);

    AddTokenRound(round.roundSupply, round.execTime, round.to, calcTotalReserveSupply());

    return true;
  }

  /**
   * @dev distribute a tobAmount from project owner defined by token creation strategy.
   * @param _distributeWei      represent a distribute ether amount for this project.
   * @param _execTime           represent a unlocking distribute time.
   * @param _maker              represent a ether receive address.
   * @param _metaData        represent a market maker name;
   */

  function addMarketMaker(uint256 _distributeWei, uint256 _execTime, address _maker, bytes32 _metaData) internal onlyOwner() returns(bool) {

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

  function getBalanceOfWei(address _sender) constant returns (uint256) {
    return weiBalances[_sender];
  }

  /**
   * @dev widthdraw ether from this contract.
   */
  
  function widthdraw() returns (bool) {

    uint256 max = weiBalances[msg.sender];

    require(this.balance >= max);

    require(msg.sender.send(max));

    weiBalances[msg.sender] = 0;

    return true;
  }

  /**
   * @dev executes TOB call from peoject owner and setup auction;
   * @param _startAuctionTime represent a unix time of auction start.
   */

  function execTOB(uint256 _startAuctionTime) external onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(weiBalances[msg.sender] > ts.tobAmountWei);

    require(token.mintable(ts.po, ts.tobAmountToken, now + 180 days));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(ts.tobAmountWei);

    startAuctionTime = _startAuctionTime;

    // deployed dutch auction 
    token.mintable(address(auction), ts.proofOfDonationCapOfToken, now);

    token.mint(address(auction));

    auction.setup(token);

    status = Status.TokenTobExecuted;

    return true;

  }

  /**
   * @dev executes donate to project and call dutch auction process.
   */

  function donate() payable isAuctionStage() returns(bool) {

    require(status == Status.TokenTobExecuted);

    require(block.timestamp >= startAuctionTime);

    auction.bid.value(msg.value)(msg.sender);

    return true;

  }

  /**
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken() returns (bool) {

    auction.claimTokens(msg.sender);

    return true;

  }


  /**
   * @dev executes donate to project and call dutch auction process.
   */

  function execRound(uint256 _index) external returns (bool) {

    require(status == Status.TokenTobExecuted);

    require(_index < rounds.length && _index >= 0);

    Round memory round = rounds[_index];

    require(round.execTime < block.timestamp);

    require(token.totalSupply() <= ts.totalSupply);

    require(token.mintable(round.to, round.roundSupply, now));

    require(token.mint(round.to));

    delete rounds[_index];

    return true;
  }

  /**
   * @dev executes distribute to market maker follow this token strategy.
   */

  function execMarketMaker(uint256 _index) external onlyProjectOwner() returns(bool) {

    require(_index < mms.length && _index >= 0);

    require(status == Status.TokenTobExecuted);

    MarketMaker memory mm = mms[_index];

    require(this.balance >= mm.distributeWei);

    require(mm.maker.send(mm.distributeWei));

    return true;

  }

  /**
   * @dev calculate TotalReserveSupply sum of all rounds.
   */

  function calcTotalReserveSupply() internal constant returns(uint256) {

    uint256 totalReserveSupply = 0;

    for (uint i = 0; i < rounds.length; i++) {

      Round memory round = rounds[i];

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