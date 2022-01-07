
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SoluTokenSale is Ownable {
    enum ICOStage {
        PreICO,
        SeedICO
    }

    ICOStage public stage = ICOStage.PreICO;

    bool public isICOCompleted;
    uint256 public rate = 3100000000000;
    uint256 public tokenToSellInPreICO = 300000000 * 10 ** 18;
    uint256 public tokenToSellInSeedICO = 500000000 * 10 ** 18;

    event BuyToken(address buyer, uint256 amount, uint256 token);

    address public soluTokenAddress;
    constructor (address _soluTokenAddres) public {
        soluTokenAddress = _soluTokenAddres;
    }

    function withdrawUnsoldToken(address preSaleAddress, address seedSaleAddress) public onlyOwner {
        require(isICOCompleted,'ICO is not complete yet');

        IERC20 soluTokenContract = IERC20(soluTokenAddress);
        if(tokenToSellInPreICO > 0) {
            soluTokenContract.transfer(preSaleAddress, tokenToSellInPreICO);
        }
        if(tokenToSellInSeedICO > 0) {
            soluTokenContract.transfer(seedSaleAddress, tokenToSellInSeedICO);
        }
    }

    function setCrowdsaleStage(uint _stage) public onlyOwner {
        if(uint(ICOStage.PreICO) == _stage) {
            stage = ICOStage.PreICO;
        } else if (uint(ICOStage.SeedICO) == _stage) {
            stage = ICOStage.SeedICO;
        }

        if(stage == ICOStage.PreICO) {
            rate = 3100000000000;           // price in wei for 1 SLT
        } else if (stage == ICOStage.SeedICO) {
            rate = 6200000000000;           // price in wei for 1 SLT
        }
    }

    function setICOCompleted(bool complete) public onlyOwner {
        isICOCompleted = complete;
    }

    function buy() public payable {
        require(!isICOCompleted, 'ICO Completed');
        require(msg.value > 0, 'Amount must be Greater than ZERO');

        
        uint256 tokenToBuy = (msg.value * 10 ** 18) / rate;
        
        if(stage == ICOStage.PreICO){
            require(tokenToSellInPreICO > 0, 'PreICO Limit Exceed');
        } else if(stage == ICOStage.SeedICO){
            require(tokenToSellInSeedICO > 0, 'SeedICO Limit Exceed');
        }
        
        IERC20 soluTokenContract = IERC20(soluTokenAddress);
        bool test = soluTokenContract.transfer(msg.sender, tokenToBuy);
        require(test,'Something went wrong');
        emit BuyToken(msg.sender, msg.value, tokenToBuy);
        
        if(stage == ICOStage.PreICO){
            tokenToSellInPreICO -= tokenToBuy;
        } else if(stage == ICOStage.SeedICO){
            tokenToSellInSeedICO -= tokenToBuy;
        }
        
    }
}