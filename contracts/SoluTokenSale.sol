
pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SoluTokenSale is Ownable {
    enum ICOStage {
        PreICO,
        SeedICO,
        FinalSale
    }

    ICOStage public stage = ICOStage.PreICO;

    bool public isICOCompleted;
    uint256 public rate = 312500;
    uint256 public tokenToSellInPreICO = 300000000 * 10 ** 18;
    uint256 public tokenToSellInSeedICO = 500000000 * 10 ** 18;

    uint256 public tokenRaisedInPreICO = 0;
    uint256 public tokenRaisedInSeedICO = 0;

    event BuyToken(address buyer, uint256 amount, uint256 token);

    address public soluTokenAddress;
    constructor (address _soluTokenAddres) public {
        soluTokenAddress = _soluTokenAddres;
    }

    function withdrawUnsoldToken(address preSaleAddress, address seedSaleAddress) public payable onlyOwner {
        require(isICOCompleted,'ICO is not complete yet');

        if(tokenToSellInPreICO > 0) {
            IERC20 soluToken = IERC20(soluTokenAddress);
            soluToken.transfer(preSaleAddress, tokenToSellInPreICO);
        }
        if(tokenToSellInSeedICO > 0) {
        IERC20 soluTokenC = IERC20(soluTokenAddress);
            soluTokenC.transfer(seedSaleAddress, tokenToSellInSeedICO);
        }
    }

    function setCrowdsaleStage(uint _stage) public onlyOwner {
        if(uint(ICOStage.PreICO) == _stage) {
            stage = ICOStage.PreICO;
        } else if (uint(ICOStage.SeedICO) == _stage) {
            stage = ICOStage.SeedICO;
        } else if(uint(ICOStage.FinalSale) == _stage) {
            stage = ICOStage.FinalSale;
            isICOCompleted = true;
        }

        if(stage == ICOStage.PreICO) {
            rate = 312500;
        } else if (stage == ICOStage.SeedICO) {
            rate = 625000;
        }
    }

    function setICOCompleted(bool complete) public onlyOwner {
        isICOCompleted = complete;
    }

    function buy() public payable {
        require(!isICOCompleted, 'ICO Completed');
        require(msg.value > 0, 'Amount must be Greater than ZERO');

        
        uint256 tokenToBuy = msg.value * rate;
        
        if(stage == ICOStage.PreICO){
            require((tokenToSellInPreICO - tokenToBuy) >= 0, 'PreICO Limit Exceed');
        } else if(stage == ICOStage.SeedICO){
            require((tokenToSellInSeedICO - tokenToBuy) >= 0, 'SeedICO Limit Exceed');
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
