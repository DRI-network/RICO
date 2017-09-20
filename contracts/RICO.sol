/**
 * @title SafeMath from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */
pragma solidity ^0.4.15;
import "./RICOToken.sol";
import "./SafeMath.sol";
import "./DutchAuction.sol";

contract RICO {

  using SafeMath for uint256;

  struct Round {
    uint256 roundSupply;
    uint256 execTime;
    address to;          //to => this 
  }

  struct MarketMaker {
    uint256 distributeWei;
    uint256 execTime;
    address maker;
    string  kiminonamaeha;
  }

  struct TokenStructure {
    uint256 totalSupply;
    address po;
    uint256 tobAmount;
    uint256 tobPrice;
  }

  enum Status {
    TokenInit,
    TokenCreated,
    TokenRoundCreated,
    TokenExecutedTob,
    TokenMintRound
  }

  address owner;
  address marketMaker;
  uint256 startAuctionTime;
  TokenStructure ts;
  RICOToken public token;
  DutchAuction public auction;
  
  Round[] public rounds;
  MarketMaker[] mms;
  mapping(address => uint256) weiBalances;

  Status status = Status.TokenInit;

  modifier onlyOwner() {
    require(msg.sender == owner);
    // Only owner is allowed to proceed
    _;
  }

  function RICO() {
    owner = msg.sender;
  }

  function init(uint256 _totalSupply, address _po, uint256 _tobAmount, uint256 _tobPrice) internal onlyOwner() returns(bool) {

    require(status == Status.TokenInit);

    token = new RICOToken();

    ts = TokenStructure({
      totalSupply: _totalSupply,
      po: _po,
      tobAmount: _tobAmount,
      tobPrice: _tobPrice
    });

    status = Status.TokenCreated;

    return true;
  }

  function initTokenData(string _name, string _symbol, uint8 _decimals) internal onlyOwner() returns (bool) {

    require(status == Status.TokenCreated);

    token.init(_name, _symbol, _decimals);

    return true;
  }

  function addRound(uint256 _roundSupply, uint256 _execTime, address _to) internal onlyOwner() returns (bool) {

    require(status == Status.TokenCreated);

    Round memory round = Round({
      roundSupply: _roundSupply,
      execTime: _execTime,
      to: _to
    });

    rounds.push(round);

    return true;
  }

  function addMarketMaker(uint256 _distributeWei, uint256 _execTime, address _maker, string _yourname) internal onlyOwner() returns (bool) {
    
    require(status == Status.TokenCreated);

    MarketMaker memory mm = MarketMaker({
      distributeWei: _distributeWei,
      execTime: _execTime,
      maker: _maker,
      kiminonamaeha: _yourname
    });
    
    mms.push(mm);

    return true;
  }

  function setDonation(uint256 _proofOfDonationCapOfToken, uint256 _proofOfDonationCapOfWei ) internal onlyOwner() returns (bool) {
    
    require(status == Status.TokenCreated);

    auction = new DutchAuction(ts.po, _proofOfDonationCapOfWei, _proofOfDonationCapOfToken,  8000);   //stopPrice

    token.mint(address(auction), _proofOfDonationCapOfToken);

    auction.setup(token);
   
    return true;
  }

  function tokenConfirmed() returns (bool) {

    require(status == Status.TokenCreated);

    require(msg.sender == ts.po);

    status = Status.TokenRoundCreated;
    
  }

  function deposit() payable {

    require(status == Status.TokenRoundCreated);

    require(msg.value > 0);

    weiBalances[msg.sender] = weiBalances[msg.sender].add(msg.value);

  }

  
  function execTob(uint256 _startAuctionTime) {
    
    require(status == Status.TokenRoundCreated);

    require(msg.sender == ts.po);

    uint256 amountWei = ts.tobAmount / ts.tobPrice;

    require(weiBalances[msg.sender] > amountWei);

    require(token.mint(ts.po, ts.tobAmount));

    weiBalances[msg.sender] = weiBalances[msg.sender].sub(amountWei);

    startAuctionTime = _startAuctionTime;
    
    // deploy dutch auction 
  

    status = Status.TokenExecutedTob;

  }

  function execDonation() payable {

    require(block.timestamp >= startAuctionTime);

    //da.bid(msg.sender);

    //da.bid.value(msg.value)(0);

  }

  function execRound(uint256 _index) {

    require(status == Status.TokenExecutedTob);

    Round memory round = rounds[_index];

    require(round.execTime < block.timestamp);

    require(token.totalSupply() <= ts.totalSupply);

    require(token.mint(round.to, round.roundSupply));

    delete rounds[_index];

  }

  function execMarketMaker(uint _index) {

    require(msg.sender == ts.po);

    require(status == Status.TokenExecutedTob);
    
    MarketMaker memory mm = mms[_index];

    require(mm.distributeWei <= this.balance);

    require(mm.maker.send(mm.distributeWei));

  }

  function () {
    if (status == Status.TokenRoundCreated)
       deposit(); 
    if (status == Status.TokenExecutedTob)
       execDonation();
  }


}