pragma solidity ^0.4.15;
import "./ERC20TokenStandard.sol";


/// @title Dutch auction contract - distribution of Gnosis tokens using an auction
/// @author Stefan George - <stefan@gnosis.pm> modified for RICO Framework Yusaku Senga - <syrohei@gmail.com>
contract DutchAuction {

    /*
     *  Events
     */
    event BidSubmission(address indexed sender, uint256 amount);

    /*
     *  Constants
     */
    uint public MAX_TOKENS_SUPPLY; 
    uint public WAITING_PERIOD;

    /*
     *  Storage
     */
     
    ERC20TokenStandard public token;
    address public wallet;
    address public owner;
    uint public donating;
    uint public priceFactor;
    uint public startBlocktime;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping(address => uint) public bids;
    Stages public stage;

    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        // Contract not in expected state
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        // Only owner is allowed to proceed
        _;
    }

    modifier isWallet() {
        require(msg.sender == wallet);
        // Only wallet is allowed to proceed
        _;
    }

    modifier isValidPayload(address receiver) {
        require(msg.data.length != 4 && msg.data.length != 36);
        // Payload length has to have correct length and receiver should not be dutch auction or gnosis token contract
        require(receiver != address(token));

        require(receiver != address(this));

        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice()) {
            finalizeAuction();
        }
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD) {
            stage = Stages.TradingStarted;
        }
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Contract constructor function sets owner
    /// @param _wallet Gnosis wallet
    /// @param _donating Auction minting
    /// @param _priceFactor Auction price factor
    function DutchAuction(address _wallet, uint256 _donating, uint256 _tokenSupply, uint _priceFactor) public {
        require(_wallet != 0 && _donating != 0 && _priceFactor != 0 && _tokenSupply != 0);
        // Arguments are null
        owner = msg.sender;
        wallet = _wallet;
        donating = _donating;
        MAX_TOKENS_SUPPLY = _tokenSupply;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    /// @dev Setup function sets external contracts' addresses
    /// @param _token Gnosis token address
    function setup(ERC20TokenStandard _token) public isOwner atStage(Stages.AuctionDeployed) {
        require (address(_token) != 0);
            // Argument is null
        token = _token;
        // Validate token balance
        require(token.balanceOf(this) == MAX_TOKENS_SUPPLY);

        stage = Stages.AuctionSetUp;
    }

    /// @dev Starts auction and sets startBlock
    function startAuction() public isOwner atStage(Stages.AuctionSetUp) {
        stage = Stages.AuctionStarted;
        startBlocktime = block.timestamp;
    }

    /// @dev Changes auction ceiling and start price factor before auction is started
    /// @param _donating Updated auction ceiling
    /// @param _priceFactor Updated start price factor
    function changeSettings(uint _donating, uint _priceFactor) public isOwner atStage(Stages.AuctionSetUp) {
        donating = _donating;
        priceFactor = _priceFactor;
    }

    /// @dev Calculates current token price
    /// @return Returns token price
    function calcCurrentTokenPrice() public timedTransitions returns(uint) {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

    /// @dev Returns correct stage, even if a function with timedTransitions modifier has not yet been called yet
    /// @return Returns current auction stage
    function updateStage() public timedTransitions returns(Stages) {
        return stage;
    }

    /// @dev Allows to send a bid to the auction
    /// @param receiver Bid will be assigned to this address if set
    function bid(address receiver) public payable isValidPayload(receiver) timedTransitions atStage(Stages.AuctionStarted) returns(uint amount) {
        // If a bid is done on behalf of a user via ShapeShift, the receiver address is set
        if (receiver == 0)
            receiver = msg.sender;

        amount = msg.value;
        // Prevent that more than 90% of tokens are sold. Only relevant if cap not reached
        uint maxWei = (MAX_TOKENS_SUPPLY / 10 ** 18) * calcTokenPrice() - totalReceived;
        uint maxWeiBasedOnTotalReceived = donating - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;
        // Only invest maximum possible amount
        if (amount > maxWei) {
            amount = maxWei;
            // Send change back to receiver address. In case of a ShapeShift bid the user receives the change back directly
            receiver.transfer(msg.value - amount);
        }
        // Forward funding to ether wallet
        wallet.transfer(amount);
        bids[receiver] += amount;
        totalReceived += amount;
        if (maxWei == amount) {
            // When maxWei is equal to the big amount the auction is ended and finalizeAuction is triggered
            finalizeAuction();
        }
           

        BidSubmission(receiver, amount);
    }

    /// @dev Claims tokens for bidder after auction
    /// @param receiver Tokens will be assigned to this address if set
    function claimTokens(address receiver) public isValidPayload(receiver) timedTransitions atStage(Stages.TradingStarted) {
        if (receiver == 0)
            receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10 ** 18 / finalPrice;
        bids[receiver] = 0;
        token.transfer(receiver, tokenCount);
    }

    /// @dev Calculates stop price
    /// @return Returns stop price
    function calcStopPrice() constant public returns(uint) {
        return totalReceived * 10 ** 18 / MAX_TOKENS_SUPPLY + 1;
    }

    /// @dev Calculates token price ETH/Token pair
    /// @return Returns token price
    function calcTokenPrice() constant public returns(uint) {
        return priceFactor * 10 ** 18 / (block.timestamp - startBlocktime + 75) + 1;
    }

    /*
     *  Private functions
     */
    function finalizeAuction() private {
        stage = Stages.AuctionEnded;
        if (totalReceived == donating)
            finalPrice = calcTokenPrice();
        else
            finalPrice = calcStopPrice();
        uint soldTokens = totalReceived * 10 ** 18 / finalPrice;
        // Auction contract transfers all unsold tokens to Gnosis inventory multisig
        token.transfer(wallet, MAX_TOKENS_SUPPLY - soldTokens);
        endTime = now;
    }
}