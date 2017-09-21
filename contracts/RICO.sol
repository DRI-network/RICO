/**
 * @title RICO - Responsible Initial Coin Offering
 * @author - Yusaku Senga<syrohei@gmail.com>.
 * @license let's see in LICENSE
 */
pragma solidity ^0.4.15;

import "./RICOToken.sol";
import "./SafeMath.sol";
import "./DutchAuction.sol";

contract RICO {

  using SafeMath
  for uint256;

  /// Struct

  struct Round {
    uint256 roundSupply;
    uint256 execTime;
    address to;
  }

  struct MarketMaker {
    uint256 distributeWei;
    uint256 execTime;
    address maker;
    string kiminonamae; // :) let's marketmaking!!
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
    TokenMintRound
  }

  address public owner;
  uint256 public startAuctionTime;

  TokenStructure public ts;
  RICOToken public token;
  DutchAuction public auction;
  Status public status = Status.TokenInit;
  Round[] public rounds;
  MarketMaker[] public mms;
  mapping(address => uint256) weiBalances;


  /// Event

  event AddTokenRound(uint256 supply, uint256 execTime, address to, uint256 totalReserve);
  event AddMarketMaker(uint256 distributeWei, uint256 execTime, address maker, string kiminonamae, uint256 totalReserve);
  event InitTokenData(string name, string symbol, uint8 decimasl);
  event InitStructure(uint256 totalSupply, address po, uint256 tobAmountWei, uint256 tobAmountToken);

  /// Modifier 

  modifier onlyOwner() {
    require(msg.sender == owner);
    // Only owner is allowed to proceed
    _;
  }

  modifier onlyProjectOwner() {
    require(msg.sender == ts.po);
    _;
  }

  /**
   * constructor
   * @dev set owner when this contract deployed.
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
  onlyOwner() returns(bool) 
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

    auction = new DutchAuction(ts.po, ts.proofOfDonationCapOfWei, ts.proofOfDonationCapOfToken, 8000); //stopPrice

    status = Status.TokenCreated;

    InitStructure(ts.totalSupply, ts.po, ts.tobAmountWei, ts.tobAmountToken);

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
   * @dev implement token supply defined by token creation strategies.
   * @param _roundSupply      represent a token mintable amount for this round.
   * @param _execTime         represent a unlocking time and token creation time.
   * @param _to               represent a token receive address.
   */

  function addRound(uint256 _roundSupply, uint256 _execTime, address _to) internal onlyOwner() returns(bool) {

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
   * @dev implement distribute program a tobAmount from project owner defined by token creation strategies.
   * @param _distributeWei      represent a distribute ether amount for this project.
   * @param _execTime           represent a unlocking distribute time.
   * @param _maker              represent a ether receive address.
   * @param _kiminonamae        represent a market maker name;
   */

  function addMarketMaker(uint256 _distributeWei, uint256 _execTime, address _maker, string _kiminonamae) internal onlyOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(_execTime >= block.timestamp);

    require(calcTotalDistributeWei().add(_distributeWei) <= ts.tobAmountWei);

    MarketMaker memory mm = MarketMaker({
      distributeWei: _distributeWei,
      execTime: _execTime,
      maker: _maker,
      kiminonamae: _kiminonamae
    });

    mms.push(mm);

    AddMarketMaker(mm.distributeWei, mm.execTime, mm.maker, mm.kiminonamae, calcTotalDistributeWei());

    return true;
  }

  function structureConfirm() onlyProjectOwner() returns(bool) {

    require(status == Status.TokenCreated);

    require(auction.stage() == DutchAuction.Stages.AuctionDeployed);

    status = Status.TokenStructureConfirmed;

    return true;

  }


  /**
   * @dev executes from project owner to tob.
   */

  function deposit() payable onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(msg.value > 0);

    weiBalances[msg.sender] = weiBalances[msg.sender].add(msg.value);

    return true;

  }

  /**
   * @dev executes Tob call from peoject owner and setup auction;
   * @param 
   */

  function execTob(uint256 _startAuctionTime) external onlyProjectOwner() returns(bool) {

    require(status == Status.TokenStructureConfirmed);

    require(weiBalances[msg.sender] > ts.tobAmountWei);

    require(token.mint(ts.po, ts.tobAmountWei));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(ts.tobAmountWei);

    startAuctionTime = _startAuctionTime;

    // deployed dutch auction 
    token.mint(address(auction), ts.proofOfDonationCapOfToken);

    auction.setup(token);

    status = Status.TokenTobExecuted;

  }

  function donate() payable returns(bool) {

    require(status == Status.TokenTobExecuted);

    require(block.timestamp >= startAuctionTime);

    if (auction.stage() == DutchAuction.Stages.AuctionSetUp)
      auction.startAuction();

    if (auction.stage() == DutchAuction.Stages.AuctionStarted)
      auction.bid.value(msg.value)(msg.sender);

    return true;

    //da.bid.value(msg.value)(0);

  }

  function execRound(uint256 _index) {

    require(status == Status.TokenTobExecuted);

    require(_index < rounds.length && _index >= 0);

    Round memory round = rounds[_index];

    require(round.execTime < block.timestamp);

    require(token.totalSupply() <= ts.totalSupply);

    require(token.mint(round.to, round.roundSupply));

    delete rounds[_index];

  }

  function execMarketMaker(uint256 _index) onlyProjectOwner() returns(bool) {

    require(_index < mms.length && _index >= 0);

    require(status == Status.TokenTobExecuted);

    MarketMaker memory mm = mms[_index];

    require(this.balance >= mm.distributeWei);

    require(mm.maker.send(mm.distributeWei));

    return true;

  }

  function calcTotalReserveSupply() internal constant returns(uint256) {

    uint256 totalReserveSupply = 0;

    for (uint i = 0; i < rounds.length; i++) {

      Round memory round = rounds[i];

      totalReserveSupply = totalReserveSupply.add(round.roundSupply);

    }
    return totalReserveSupply;
  }

  function calcTotalDistributeWei() internal constant returns(uint256) {

    uint256 totalDistributeWei = 0;

    for (uint i = 0; i < rounds.length; i++) {

      MarketMaker memory mm = mms[i];

      totalDistributeWei = totalDistributeWei.add(mm.distributeWei);

    }
    return totalDistributeWei;
  }

  function calcEnsureSupply() internal constant returns(uint256) {
    return ts.tobAmountToken + ts.proofOfDonationCapOfToken;
  }

  function () {
    if (status == Status.TokenStructureConfirmed)
      deposit();
    if (status == Status.TokenTobExecuted)
      donate();
  }


}