// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//stake token done 1
//unstake token
//issuetoken done 1
//add allowedtokens done 1
//getvalue done 

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";



contract TokenFarm is Ownable{
    //mapping tokenaddress --> staker address --> amount
    mapping(address => mapping(address=>uint256)) public stakingBalance;
    
    mapping(address => uint256) public uniqueTokensStaked;
    
    mapping(address => address) public tokenPriceFeedMapping;


    address[] public allowedTokens;
    
    address[] public stakers;

    IERC20 public dappToken;

    constructor (address _dappTokenAddress)  public {
        dappToken = IERC20(_dappTokenAddress);

    }


    function setPriceFeedContract(address _token, address _priceFeed) public onlyOwner {
        tokenPriceFeedMapping[_token] = _priceFeed;
    }


    function issueTokens() public onlyOwner {
        for (
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++ ) 
            
            {
                address recipient = stakers[stakersIndex];
                uint256 userTotalValue = getUserTotalValue(recipient);
                // send them token reward
                dappToken.transfer(recipient, userTotalValue );
                //based on their total value locked


            }

    }

    function getUserTotalValue(address _user) public view returns (uint256) {
        uint256 totalValue = 0;
        require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
        for 
        (uint256 allowedTokensIndex = 0;
        allowedTokensIndex < allowedTokens.length;
        allowedTokensIndex++) {
            totalValue = totalValue + getUserSingleTokenValue(_user,allowedTokens[allowedTokensIndex]);
        }
        return totalValue;

    }

    function getUserSingleTokenValue(address _user, address _token) 
    public 
    view 
    returns (uint256) {
        // 1 ETH -> $2000
        // 200 dai -> $200
        // 200

        if (uniqueTokensStaked[_user] <= 0){
            return 0;
        }
        // price of the token * stakingBalance[_token][_user]
        (uint256 price, uint256 decimals) = getTokenValue(_token);
        return (stakingBalance[_token][_user] * price / (10 **decimals));
    }
function getTokenValue(address _token) public view returns(uint256,uint256) {
    // priceFeedAddress

        address priceFeedAddress = tokenPriceFeedMapping[_token];
        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (,int256 price, , ,)=priceFeed.latestRoundData();
        uint256 decimals = uint256(priceFeed.decimals());

        return(uint256(price), decimals);


}

    function stakeTokens(uint256 _amount, address _token) 
    public {
           require(_amount > 0, "Amount must be more than 0");
        //    require(_token is allowed) 
           require(tokenIsAllowed(_token),"Token is not currently allowed");

            IERC20(_token).transferFrom(msg.sender, address(this),_amount);
            updateUniqueTokensStaked(msg.sender, _token);
            stakingBalance[_token][msg.sender] = stakingBalance[_token][msg.sender]+_amount;
            if (uniqueTokensStaked[msg.sender]==1){
                stakers.push(msg.sender);
            }
    }


    function unStakeTokens (address _user, address _token) public {
        uint256 balance = stakingBalance[_token][msg.sender];
        require (balance > 0, "Stking balace cananot");
        IERC20(_token).transfer(msg.sender, balance);
        stakingBalance[_token][msg.sender] = 0;
        uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    }

    function updateUniqueTokensStaked(address _user, address _token) internal {
        if (stakingBalance[_token][_user] <= 0){
            uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;

        }
    }

    // 100 ETH 1:1 for every 1 ETH, WE GIVE 1 DAPP TOKEN
    // 50 ETH AND 50 DAI STAKED, AND WE WANT TO GIVE A REWARD OF 1 DAPP/1DAI
    
    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }
    
    
    function tokenIsAllowed(address _token) public returns(bool){
        for(uint256 allowedTokensIndex=0; allowedTokensIndex < allowedTokens.length; allowedTokensIndex++){
            if (allowedTokens[allowedTokensIndex] == _token){
                return true;
            }
            return false;
        }
    }
}