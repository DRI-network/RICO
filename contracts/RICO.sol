pragma solidity ^0.4.18;
import "./MintableToken.sol";
import "./PoD.sol";

/// @title RICO - Responsible Initial Coin Offering
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE
/// @notice TokenRound chose a index for pod execute modes. 
/// 0. Attach ToB pod. podType == 101
/// 1~ Attach Custom pod. podType == 111

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
  event ExecutedTOB(address po);
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
    RICOStarted
  }

  address public po;
  uint256 public totalSupply;
  uint256 public tobLimitWei;
  uint256 public nowReserveWei;
  uint256 public startTimeOfPoD;
  Status public status;
  string public version = "0.9.2";
  address[] public tokens;

  mapping(address => mapping(uint256 => uint256)) wLimitWei;
  mapping(address => address[]) tokenToPods;
  mapping(address => uint256) totalSupplies;
  /**
   * constructor
   * @dev define owner when this contract deployed.
   */

  function RICO() public {
    status = Status.Deployed;
  }

  /**
   * @dev newToken token meta Data implement for ERC-20 Token Standard Format.
   * @param _name         set Token name of RICO format.
   * @param _symbol       set Token symbol of RICO format.
   * @param _decimals     set Token decimals of RICO format.
   */
  function newToken(string _name, string _symbol, uint8 _decimals, address _po) public returns (address) {

    MintableToken token = new MintableToken();

    token.init(_name, _symbol, _decimals, _po);

    tokens.push(address(token));

    InitTokenData(_name, _symbol, _decimals);

    return address(token);
  }
  /**
   * @dev initialize token structure for new project.
   * @param _pods                       array of Pod's addresses
   * @param _token                      total supply of Token.
   */
  function init(address[] _pods, address _tokenAddr, uint256 _totalSupply) public returns(bool) {

    require(tokenToPods[_tokenAddr].length == 0);

    MintableToken token = MintableToken(_tokenAddr);

    require(token.po() == msg.sender);

    tokenToPods[_tokenAddr] = _pods;

    totalSupplies[_tokenAddr] = _totalSupply;

    return true;
  }


  /**
   * @dev confirm token creation strategy by projectOwner.
   */

  function strategyConfirm(address _tokenAddr) public onlyProjectOwner() returns(bool) {

    MintableToken token = MintableToken(_tokenAddr);

    require(token.po() == msg.sender);

    require(checkTotalSupply(_tokenAddr));

    return true;

  }

  function startPoD(address _tokenAddr, uint _pod, uint256 _startTimeOfPoD) public returns(bool) {
  
    require(tokenToPods[_tokenAddr][_pod] != 0x0);

    PoD pod = PoD(tokenToPods[_tokenAddr][_pod]);

    require(_startTimeOfPoD >= block.timestamp);

    require(pod.start(startTimeOfPoD));

    return true;
  }

  function checkTotalSupply(address _tokenAddr) internal constant returns (bool) {
    uint256 nowSupply = 0;
    for (uint i = 0; i < tokenToPods[_tokenAddr].length-1; i++) {
      address podAddr = tokenToPods[_tokenAddr][i];
      PoD pod = PoD(podAddr);
      nowSupply = nowSupply.add(pod.proofOfDonationCapOfToken());
    }
    if (nowSupply <= totalSupplies[_tokenAddr])
      return true;
    return false;
  }

  /**
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken(address _tokenAddr, uint _pod, address _user) public returns(bool) {

    require(tokenToPods[_tokenAddr][_pod] != 0x0);

    PoD pod = PoD(tokenToPods[_tokenAddr][_pod]);

    require(pod.isPoDEnded());

    uint256 tokenValue = pod.getBalanceOfToken(_user);

    require(tokenValue > 0);

    MintableToken token = MintableToken(_tokenAddr);

    require(token.mint(_user, tokenValue));

    require(pod.resetWeiBalance(_user));

    return true;
  }
}