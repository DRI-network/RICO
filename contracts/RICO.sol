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

  event CreatedNewProject(string name, string symbol, uint8 decimals, uint256 supply, address po, address[] pods, address token);

  /**
   * Storage
   */

  string public version = "0.9.2";
  address[] public tokens;

  mapping(address => address[]) tokenToPods;
  mapping(address => uint256) totalSupplies;
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
    uint256 _totalSupply,
    address[] _pods
  ) 
  public returns (address) 
  {

    require(checkPoDs(_totalSupply, _pods));

    MintableToken token = new MintableToken();

    token.init(_name, _symbol, _decimals, msg.sender);

    tokenToPods[token] = _pods;

    totalSupplies[token] = _totalSupply;

    tokens.push(token);

    CreatedNewProject(_name, _symbol, _decimals, _totalSupply, msg.sender, _pods, token);

    return address(token);
  }


  /**
   * @dev confirm token creation strategy by projectOwner.
   */

  function checkPoDs(uint256 _totalSupply, address[] _pods) internal constant returns (bool) {
    uint256 nowSupply = 0;
    for (uint i = 0; i < _pods.length-1; i++) {
      address podAddr = _pods[i];
      PoD pod = PoD(podAddr);

      if (!pod.isPoDStarted())
        return false;

      nowSupply = nowSupply.add(pod.proofOfDonationCapOfToken());
    }
    if (nowSupply <= _totalSupply)
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