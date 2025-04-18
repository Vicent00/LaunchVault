// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IAgregator.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/**
 * @title Presale Contract
 * @dev This contract manages a token presale with multiple phases, supporting ETH, USDT, and USDC payments
 * @notice The presale has different phases with varying prices and time limits
 */
contract Presale is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    /// @notice Address of USDT token contract
    address public usdtAdress;
    /// @notice Address of USDC token contract
    address public usdcAdress;

    /// @notice Address of the token being sold
    address public tokenAdress;
    /// @notice Address of Chainlink price feed oracle
    address public dataFeedAdress;
    
    /// @notice Array containing presale phases [amount, price, time]
    uint256[][3] public phases;
    /// @notice Current active phase of the presale
    uint256 public currentPhase;

    /// @notice Maximum amount of tokens that can be sold
    uint256 public maxSellingAmount;
    /// @notice Total amount of tokens sold so far
    uint256 public totalSold;

    /// @notice Address where raised funds will be sent
    address public fundsReceiverAddress;
    /// @notice Start time of the presale
    uint256 public startTime;
    /// @notice End time of the presale
    uint256 public endTime;

    /// @notice Mapping of user addresses to their token balances
    mapping(address => uint256) public userTokenBalance;
    /// @notice Mapping of blacklisted addresses
    mapping(address => bool) public isBlacklisted;

    // Events

    event TokensPurchased(address indexed user, uint256 tokenAmount, uint256 amount);
    event TokensBoughtETH(address indexed user, uint256 tokenAmount, uint256 amount);
    event PhaseUpdated(uint256 indexed oldPhase, uint256 indexed newPhase);
    event PresaleStarted(uint256 startTime, uint256 endTime);
    event PresaleEnded(uint256 totalSold, uint256 totalRaised);
    event TokensClaimed(address indexed user, uint256 amount);
    event BlacklistUpdated(address indexed user, bool isBlacklisted);


    /**
     * @dev Constructor to initialize the presale contract
     * @param _usdtAdress Address of USDT token
     * @param _usdcAdress Address of USDC token
     * @param _tokenAdress Address of the token being sold
     * @param _dataFeedAdress Address of Chainlink price feed
     * @param _phases Array of presale phases [amount, price, time]
     * @param _maxSellingAmount Maximum amount of tokens to be sold
     * @param _fundsReceiverAddress Address to receive raised funds
     * @param _startTime Start time of the presale
     * @param _endTime End time of the presale
     */
    constructor(
        address _usdtAdress,
        address _usdcAdress,
        address _tokenAdress,
        address _dataFeedAdress,
        uint256[][3] memory _phases,
        uint256 _maxSellingAmount,
        address _fundsReceiverAddress,
        uint256 _startTime,
        uint256 _endTime
    ) Ownable(msg.sender) {
        usdtAdress = _usdtAdress;
        usdcAdress = _usdcAdress;
        tokenAdress = _tokenAdress;
        dataFeedAdress = _dataFeedAdress;
        phases = _phases;
        maxSellingAmount = _maxSellingAmount;
        fundsReceiverAddress = _fundsReceiverAddress;
        startTime = _startTime;
        endTime = _endTime;

        require(endTime > startTime, "End time must be greater than start time");
        // transfer tokens to presale contract or Deploying contract
        IERC20(tokenAdress).safeTransferFrom(msg.sender, address(this), maxSellingAmount);
    }

    /**
     * @dev Adds an address to the blacklist
     * @param user_ Address to be blacklisted
     */
    function addToBlacklist(address user_) external onlyOwner {
        isBlacklisted[user_] = true;
        emit BlacklistUpdated(user_, true);
    }

    /**
     * @dev Removes an address from the blacklist
     * @param user_ Address to be removed from blacklist
     */
    function removeFromBlacklist(address user_) external onlyOwner {
        isBlacklisted[user_] = false;
        emit BlacklistUpdated(user_, false);
    }

    /**
     * @dev Emergency function to withdraw ERC20 tokens
     * @param tokenAddress_ Address of the token to withdraw
     * @param amount_ Amount of tokens to withdraw
     */
    function emergencyWithdrawERC20(address tokenAddress_, uint256 amount_) external onlyOwner {
       
        IERC20(tokenAddress_).safeTransfer(msg.sender, amount_);
    }

    /**
     * @dev Emergency function to withdraw ETH
     */
    function emergencyWithdrawEth() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }


   /**
    * @dev Gets the latest ETH price from Chainlink oracle
    * @return uint256 Current ETH price in USD
    */
   function getETHPrice() public view returns (uint256) {
   
   (,int256 price,,,) = IAggregator(dataFeedAdress).latestRoundData();
   return uint256(price);
   }


   /**
    * @dev Checks and updates the current phase of the presale
    * @param amount_ Amount of tokens being purchased
    * @return uint256 Updated phase number
    */
   function checkCurrentPhase(uint256 amount_) private returns (uint256) {
        uint256 oldPhase = currentPhase;
        if ((totalSold + amount_ <= phases[currentPhase][0] || block.timestamp >= phases[currentPhase][2]) && currentPhase < 3) {
            currentPhase++;
            emit PhaseUpdated(oldPhase, currentPhase);
        }
        return currentPhase;
    }
// Presale functions Buy tokens eth or usdt or usdc

function buyTokensERC20(address tokenUsedToBuy_, uint256 amount_) external nonReentrant {

    require(!isBlacklisted[msg.sender], "User is blacklisted");
    require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale is not active");
    require(amount_ > 0, "Amount must be greater than 0");
    require(tokenUsedToBuy_ == usdtAdress || tokenUsedToBuy_ == usdcAdress, "Invalid token address");

    uint256 tokenAmountToReceive;
    if (ERC20(tokenUsedToBuy_).decimals() == 18) tokenAmountToReceive = amount_ * 1e6 / phases[currentPhase][1];
    else tokenAmountToReceive = amount_ * 10 **(18 - ERC20(tokenUsedToBuy_).decimals()) * 1e6 / phases[currentPhase][1];
    checkCurrentPhase(tokenAmountToReceive);
    
    totalSold += tokenAmountToReceive;
    require(totalSold <= maxSellingAmount, "Presale is over");

    // aumentar el balance del usuario

    userTokenBalance[msg.sender] += tokenAmountToReceive;

    // transferir tokens a usuario
    IERC20(tokenUsedToBuy_).safeTransferFrom(msg.sender, address(this), amount_);

    // Eventos 
    emit TokensPurchased(msg.sender, tokenAmountToReceive, amount_);


    }


function buyTokensEth() external payable nonReentrant {
    require(!isBlacklisted[msg.sender], "User is blacklisted");
    require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale is not active");
    require(msg.value > 0, "Amount must be greater than 0");

    uint256 usdValue = msg.value * getETHPrice() / 1e18;
    uint256 tokenAmountToReceive = usdValue * 1e6 / phases[currentPhase][1];
    checkCurrentPhase(tokenAmountToReceive);

    totalSold += tokenAmountToReceive;
    require(totalSold <= maxSellingAmount, "Presale is over");

// Balance de usuario
    userTokenBalance[msg.sender] += tokenAmountToReceive;

// transferir tokens a usuario
    (bool success, ) = msg.sender.call{value: msg.value}("");
    require(success, "Transfer failed");

// Eventos
    emit TokensBoughtETH(msg.sender, tokenAmountToReceive, msg.value);


    }


    // Claim Tokens
    function claimTokens() external nonReentrant {

        require(userTokenBalance[msg.sender] > 0, "No tokens to claim");
        require(block.timestamp > endTime, "Presale is not over");

        uint256 tokenAmount = userTokenBalance[msg.sender];
       delete userTokenBalance[msg.sender];

        IERC20(tokenAdress).safeTransfer(msg.sender, tokenAmount);
        emit TokensClaimed(msg.sender, tokenAmount);
        
        if (totalSold >= maxSellingAmount) {
            emit PresaleEnded(totalSold, address(this).balance);
        }


    }





    
}
