pragma solidity ^0.4.18;
import "./MintableToken.sol";
import "./AbsPoD.sol";

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