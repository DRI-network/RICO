pragma solidity ^0.4.18;
import "../PoD.sol";
/// @title PoDStrategy - PoDStrategy contract
/// @author - Yusaku Senga - <senga@dri.network>
/// license let's see in LICENSE

contract SimplePoD is PoD {

  function SimplePoD() public {
    name = "SimplePoD strategy token price = capToken/capWei ";
    version = 1;
    startTime = 1922344;
    endTime = 49999999;
  }

  function start() public Start() {
    require(startTime );
  }
}
