pragma solidity ^0.4.18;

// File: contracts/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/SafeMath.sol

/**
 * @title SafeMath from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/PoD.sol

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

// File: contracts/PoDs/DutchAuctionPoD.sol

/// @title DutchAuctionPoD - DutchAuction module contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract DutchAuctionPoD is PoD {

  /*
   * Storage
   */

  // Starting price in WEI; e.g. 2 * 10 ** 18
  uint256 public priceStart;

  // Divisor constant; e.g. 524880000
  uint256 public priceConstant;
  // Divisor exponent; e.g. 3
  uint32 public priceExponent;
  // Token tokenMultiplier; e.g. 18
  uint256 public tokenMultiplier;

  uint256 proofOfDonationCapOfToken;
  uint256 proofOfDonationCapOfWei;
  /*
   * Modifiers
   */
  modifier atStatus(Status _status) {
    require(status == _status);
    _;
  }

  /*
   * Events
   */

  event Setup(uint indexed _startPrice, uint indexed _priceConstant, uint32 indexed _priceExponent);
  event AuctionStarted(uint indexed _startTime, uint indexed _blockNumber);
  event BidSubmission(address indexed _sender, uint _amount, uint _missingFunds);
  event AuctionEnded(uint _finalPrice);

  /*
   * Public functions
   */

  /// @dev Contract constructor function 
  function DutchAuctionPoD() public { 
    name = "DutchAuction strategy PoD";
    version = "0.9.3";
  }

  function init(
    address _wallet,
    uint8 _tokenDecimals,
    uint _priceStart,
    uint _priceConstant,
    uint32 _priceExponent,
    uint256 _capOfToken
  )
  public onlyOwner() atStatus(Status.PoDDeployed) returns(bool)
  {
    require(_tokenDecimals != 0);
    require(_priceStart > 0);
    require(_priceConstant > 0);
    require(_wallet != 0x0);
    wallet = _wallet;
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    priceStart = _priceStart;
    priceConstant = _priceConstant;
    priceExponent = _priceExponent;
    proofOfDonationCapOfToken = _capOfToken;
    status = Status.PoDStarted;
    Setup(_priceStart, _priceConstant, _priceExponent);
    
    return true;
  }

  /// --------------------------------- Auction Functions ------------------

  /// @notice Finalize the auction - sets the final Token price and changes the auction
  /// stage after no bids are allowed anymore.
  /// @dev Finalize auction and set the final Token price.
  function finalizeAuction() public atStatus(Status.PoDStarted) {
    // Missing funds should be 0 at this point
    uint missingFunds = missingFundsToEndAuction();
    require(missingFunds == 0);

    // Calculate the final price = WEI / Token
    // Reminder: num_tokens_auctioned is the number of Rei (Token * token_multiplier) that are auctioned
    tokenPrice = tokenMultiplier * totalReceivedWei / proofOfDonationCapOfToken;

    endTime = now;

    AuctionEnded(tokenPrice);

    status = Status.PoDEnded;

    assert(tokenPrice > 0);
  }



  /// @notice Get the Token price in WEI during the auction, at the time of
  /// calling this function. Returns `0` if auction has ended.
  /// Returns `price_start` before auction has started.
  /// @dev Calculates the current Token price in WEI.
  /// @return Returns WEI per Token (token_multiplier * Rei).
  function price() public constant returns(uint) {
    if (status == Status.PoDEnded) {
      return 0;
    }
    return calcTokenPrice();
  }

  /// @notice Get the missing funds needed to end the auction,
  /// calculated at the current Token price in WEI.
  /// @dev The missing funds amount necessary to end the auction at the current Token price in WEI.
  /// @return Returns the missing funds amount in WEI.
  function missingFundsToEndAuction() public constant returns(uint) {

    // num_tokens_auctioned = total number of Rei (Token * token_multiplier) that is auctioned
    uint requiredWeiAtPrice = proofOfDonationCapOfToken * price() / tokenMultiplier;
    if (requiredWeiAtPrice <= totalReceivedWei) {
      return 0;
    }

    // assert(required_wei_at_price - received_wei > 0);
    return requiredWeiAtPrice - totalReceivedWei;
  }

  /*
   *  Private functions
   */

  /// @dev Calculates the token price (WEI / Token) at the current timestamp
  /// during the auction; elapsed time = 0 before auction starts.
  /// Based on the provided parameters, the price does not change in the first
  /// `price_constant^(1/price_exponent)` seconds due to rounding.
  /// Rounding in `decay_rate` also produces values that increase instead of decrease
  /// in the beginning; these spikes decrease over time and are noticeable
  /// only in first hours. This should be calculated before usage.
  /// @return Returns the token price - Wei per Token.
  function calcTokenPrice() constant private returns(uint) {
    uint elapsed;
    if (status == Status.PoDStarted) {
      elapsed = now - startTime;
    }

    uint decayRate = elapsed ** priceExponent / priceConstant;
    return priceStart * (1 + elapsed) / (1 + elapsed + decayRate);
  }

  /// Inherited functions


  /// @notice Send `msg.value` WEI to the auction from the `msg.sender` account.
  /// @dev Allows to send a bid to the auction.
  function processDonate(address _user) internal returns (bool) {
    require(msg.value > 0);
    require(_user != 0x0);
    assert(weiBalances[_user].add(msg.value) >= msg.value);

    // Missing funds without the current bid value
    uint missingFunds = missingFundsToEndAuction();

    // We require bid values to be less than the funds missing to end the auction
    // at the current price.
    require(msg.value <= missingFunds);

    weiBalances[_user] = weiBalances[_user].add(msg.value);

    // Send bid amount to wallet
    BidSubmission(msg.sender, msg.value, missingFunds);

    //assert(totalReceivedWei >= msg.value);
    return true;
  }

  function getBalanceOfToken(address _user) public constant returns(uint) {
    
    uint num = (tokenMultiplier * weiBalances[_user]) / tokenPrice;
    return num;
  }
}

// File: contracts/PoDs/RICOStandardPoD.sol

/// @title RICOStandardPoD - RICOStandardPoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICOStandardPoD is PoD {

  address public buyer;
  address[] public marketMakers;
  uint256 public tokenMultiplier;
  uint256 public secondCapOfToken;

  function RICOStandardPoD() public {
    name = "StandardPoD strategy tokenPrice = capToken/capWei";
    version = "0.9.3";
  }

  function init(
    uint256 _startTimeOfPoD,
    uint8 _tokenDecimals, 
    uint256 _capOfToken, 
    uint256 _capOfWei, 
    address[2] _owners,
    address[] _marketMakers,
    uint256 _secondCapOfToken
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);

    require(_startTimeOfPoD >= block.timestamp);
   
    startTime = _startTimeOfPoD;
  
    wallet = this;

    marketMakers = _marketMakers;

    tokenMultiplier = 10 ** uint256(_tokenDecimals);

    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;

    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;

    buyer = _owners[0];
    weiBalances[_owners[1]] = 1;

    secondCapOfToken = _secondCapOfToken;

    status = Status.PoDStarted;
    
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    
    require(msg.sender == buyer);
    
    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }

  function distributeWei(uint _index, uint256 _amount) public returns (bool) {

    require(msg.sender == buyer);

    require(_amount <= this.balance);

    marketMakers[_index].transfer(_amount);

    return true;
  }


  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp < startTime.add(180 days))
      return 0;

    if (_user == buyer)
      return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
    else 
      return secondCapOfToken * weiBalances[_user];
  }

  function resetWeiBalance(address _user) public onlyOwner() returns (bool) {

    require(status == Status.PoDEnded);

    weiBalances[_user] = 0;

    return true;

  }
}

// File: contracts/PoDs/SimplePoD.sol

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract SimplePoD is PoD {

  uint256 public tokenMultiplier;
  uint256 public period;

  function SimplePoD() public {
    name = "SimplePoD strategy token price = capToken/capWei";
    version = "0.9.3";
  }

  function init(
    address _wallet, 
    uint256 _startTimeOfPoD,
    uint8 _tokenDecimals,
    uint256 _capOfToken, 
    uint256 _capOfWei
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    require(_wallet != 0x0);
    startTime = _startTimeOfPoD;
    wallet = _wallet;
    tokenMultiplier = 10 ** uint256(_tokenDecimals);
    proofOfDonationCapOfToken = _capOfToken;
    proofOfDonationCapOfWei = _capOfWei;
    tokenPrice = tokenMultiplier * proofOfDonationCapOfWei / proofOfDonationCapOfToken;
    period = 7 days;
    status = Status.PoDStarted;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {

    require(block.timestamp <= startTime.add(period));

    uint256 remains = proofOfDonationCapOfWei.sub(totalReceivedWei);

    require(msg.value <= remains);
    
    weiBalances[_user] = weiBalances[_user].add(msg.value);

    if (msg.value == remains)
      return false;
    
    return true;
  }

  function finalize() public {

    require(status == Status.PoDStarted);

    require(block.timestamp > startTime.add(period));

    endTime = now;

    status = Status.PoDEnded;

    Ended(endTime);
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    return (tokenMultiplier * weiBalances[_user]) / tokenPrice;
  }
}

// File: contracts/PoDs/TokenMintPoD.sol

/// @title SimplePoD - SimplePoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract TokenMintPoD is PoD {

  mapping(address => uint256) tokenBalances; 
  uint256 public lockTime;
  
  function TokenMintPoD() public {
    name = "TokenMintPoD mean that minting Token to user";
    version = "0.9.3";
  }

  function init(
    address _user, 
    uint256 _capOfToken,
    uint256 _lockTime
  ) 
  public onlyOwner() returns (bool) 
  {
    require(status == Status.PoDDeployed);
    proofOfDonationCapOfToken = _capOfToken;
    tokenBalances[_user] = proofOfDonationCapOfToken;
    lockTime = _lockTime;
    weiBalances[_user] = 1;
    status = Status.PoDStarted;
    return true;
  }

  function processDonate(address _user) internal returns (bool) {
    assert(_user != 0x0);
    return false;
  }

  function getBalanceOfToken(address _user) public constant returns (uint256) {
    if (block.timestamp <= lockTime) 
      return 0;

    return weiBalances[_user].mul(tokenBalances[_user]);
  }
}

// File: contracts/AbsPoD.sol

/// @title AbsPoD - Abstract PoD contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract AbsPoD {

  function resetWeiBalance(address _user) public returns(bool);

  function getBalanceOfToken(address _user) public constant returns(uint256);

  function transferOwnership(address newOwner) public;

  function getCapOfToken() public constant returns(uint256);

  function isPoDStarted() public constant returns(bool);

  function isPoDEnded() public constant returns(bool);

  function getTokenPrice() public constant returns(uint256);

  function getStartTime() public constant returns (uint256);

  function getEndtime() public constant returns(uint256);

}

// File: contracts/EIP20Token.sol

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
// https://github.com/ConsenSys/Tokens/blob/master/contracts/Token.sol
pragma solidity ^0.4.18;

contract EIP20Token {
  /* This is a slight change to the ERC20 base standard.
  function totalSupply() constant returns (uint256 supply);
  is replaced with:
  uint256 public totalSupply;
  This automatically creates a getter function for the totalSupply.
  This is moved to the base contract since public getter functions are not
  currently recognised as an implementation of the matching abstract
  function by the compiler.
  */
  /// total amount of tokens
  uint256 public totalSupply;

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public constant returns(uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) public returns(bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns(bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public constant returns(uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/EIP20StandardToken.sol

/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
based on the https://github.com/ConsenSys/Tokens/blob/master/contracts/StandardToken.sol
.*/
pragma solidity ^0.4.18;



contract EIP20StandardToken is EIP20Token {

  uint256 constant MAX_UINT256 = 2 ** 256 - 1;

  function transfer(address _to, uint256 _value) public returns(bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
    require(balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
    //same as above. Replace this line with the following if you want to protect against wrapping uints.
    //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
    uint256 allowance = allowed[_from][msg.sender];
    require(balances[_from] >= _value && allowance >= _value);
    balances[_to] += _value;
    balances[_from] -= _value;
    if (allowance < MAX_UINT256) {
      allowed[_from][msg.sender] -= _value;
    }
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant public returns(uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public returns(bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
    return allowed[_owner][_spender];
  }

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) allowed;
}

// File: contracts/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is EIP20StandardToken, Ownable {
  using SafeMath for uint256;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;
  bool public initialized = false;
  string public name;
  string public symbol;
  uint8 public decimals;
  address public projectOwner;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function MintableToken() public {}

  function init(string _name, string _symbol, uint8 _decimals, address _projectOwner) onlyOwner() public returns (bool) {
    require(!initialized);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    projectOwner = _projectOwner;
    initialized = true;
    return initialized;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner() canMint() public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() canMint() public returns (bool) {
    require(msg.sender == projectOwner);
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/RICO.sol

/// @title RICO - Responsible Initial Coin Offering
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract RICO is Ownable {
  /// using safemath
  using SafeMath for uint256;
  /**
   * Events 
   */

  event CreatedNewProject(string name, string symbol, uint8 decimals, uint256 supply, address[] pods, address token);
  event CheckedPodsToken(address pod, uint256 supply);

  /**
   * Storage
   */

  string public name = "RICO contract";
  string public version = "0.9.3";
  address[] public tokens;

  mapping(address => address[]) tokenToPods;
  mapping(address => uint256) public maxSupplies;
  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function RICO() public { }

  /**
   * @dev newToken token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name of RICO format.
   * @param _symbol       set Token symbol of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   * @param _pods         set PoD contract addresses.
   * @param _projectOwner set Token's owner.
   */
  function newProject(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address[] _pods,
    address _projectOwner
  ) 
  public returns (address) 
  {
    uint256 totalSupply = checkPoDs(_pods);

    require(totalSupply > 0);
    
    //generate a ERC20 mintable token.
    MintableToken token = new MintableToken();

    token.init(_name, _symbol, _decimals, _projectOwner);

    tokenToPods[token] = _pods;

    maxSupplies[token] = totalSupply;

    tokens.push(token);

    CreatedNewProject(_name, _symbol, _decimals, totalSupply, _pods, token);

    return address(token);
  }


  /**
   * @dev To confirm pods and check the token maximum supplies.
   * @param _pods         set PoD contract addresses.
   */

  function checkPoDs(address[] _pods) internal returns (uint256) {
    uint256 nowSupply = 0;
    for (uint i = 0; i < _pods.length; i++) {
      address podAddr = _pods[i];
      AbsPoD pod = AbsPoD(podAddr);

      if (!pod.isPoDStarted())
        return 0;
      
      uint256 capOfToken = pod.getCapOfToken();
      nowSupply = nowSupply.add(capOfToken);
      CheckedPodsToken(address(pod), capOfToken);
    }

    return nowSupply;
  }

  /**
   * @dev executes claim token when pod's status was ended.
   * @param _tokenAddr         set the project's token address.
   * @param _index             set a pods num of registered array.
   * @param _user              set a minter address.
   */

  function mintToken(address _tokenAddr, uint _index, address _user) public returns(bool) {

    address user = msg.sender;
 
    if (_user != 0x0) {
      user = _user;
    }

    require(tokenToPods[_tokenAddr][_index] != 0x0);

    AbsPoD pod = AbsPoD(tokenToPods[_tokenAddr][_index]);

    require(pod.isPoDEnded());

    uint256 tokenValue = pod.getBalanceOfToken(user);

    require(tokenValue > 0);

    MintableToken token = MintableToken(_tokenAddr);

    require(token.mint(user, tokenValue));

    require(pod.resetWeiBalance(user));

    return true;
  }
  

  /**
   * @dev To get pods addresses attached to token.
   */

  function getTokenPods(address _token) public constant returns (address[]) {
    return tokenToPods[_token];
  }
}

// File: contracts/Launcher.sol

/// @title Launcher - RICO Launcher contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE


contract Launcher {

  /**
   * Storage
   */
  string public name = "RICO Launcher";
  string public version = "0.9.3";
  RICO public rico;
  bool state = false;
  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function Launcher() public {}

  /**
   * @dev init rico contract.
   * @param _rico         set rico address.
   */
  function init(address _rico) public {
    require(!state);
    rico = RICO(_rico);
    state = true;
  }


  /**
   * @dev newToken token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name of RICO format.
   * @param _symbol       set Token symbol of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   */
  
  function kickStartA(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address _wallet,
    uint256[] _tobParams,
    uint256[] _podParams,
    address[2] _owners,
    address[] _marketMakers
  ) 
  public 
  {
    address[] memory pods = new address[](2);
    RICOStandardPoD tob = new RICOStandardPoD();
    tob.init(_tobParams[0], _decimals, _tobParams[1], _tobParams[2], _owners, _marketMakers, _tobParams[3]);
    pods[0] = address(tob);

    SimplePoD pod = new SimplePoD();
    pod.init(_wallet, _podParams[0], _decimals, _podParams[1], _podParams[2]);
    pods[1] = address(pod);

    rico.newProject(_name, _symbol, _decimals, pods, _wallet);
  }
}
