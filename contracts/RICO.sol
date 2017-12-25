pragma solidity ^0.4.18;
import "./MintableToken.sol";
import "./AbsPoD.sol";

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

  event CreatedNewProject(string name, string symbol, uint8 decimals, uint256 supply, address[] pods, address token);
  event CheckedPodsToken(address pod, uint256 supply);

  /**
   * Storage
   */

  string public name = "RICO contract";
  string public version = "0.9.3";
  address[] public tokens;

  mapping(address => address[]) public tokenToPods;
  mapping(address => uint256) public totalSupplies;
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
   */
  function newProject(
    string _name, 
    string _symbol, 
    uint8 _decimals, 
    address[] _pods
  ) 
  public returns (address) 
  {
    uint256 totalSupply = checkPoDs(_pods);

    require(totalSupply > 0);
    
    //generate a ERC20 mintable token.
    MintableToken token = new MintableToken();

    token.init(_name, _symbol, _decimals);

    tokenToPods[token] = _pods;

    totalSupplies[token] = totalSupply;

    tokens.push(token);

    CreatedNewProject(_name, _symbol, _decimals, totalSupply, _pods, token);

    return address(token);
  }


  /**
   * @dev confirm token creation strategy by projectOwner.
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
   * @dev executes claim token when auction trading time elapsed.
   */

  function mintToken(address _tokenAddr, uint _pod, address _user) public returns(bool) {

    require(tokenToPods[_tokenAddr][_pod] != 0x0);

    AbsPoD pod = AbsPoD(tokenToPods[_tokenAddr][_pod]);

    require(pod.isPoDEnded());

    uint256 tokenValue = pod.getBalanceOfToken(_user);

    require(tokenValue > 0);

    MintableToken token = MintableToken(_tokenAddr);

    require(token.mint(_user, tokenValue));

    require(pod.resetWeiBalance(_user));

    return true;
  }
}