
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
    uint256 public tokenToSellInFinalSale = 0;

    event BuyToken(address buyer, uint256 amount, uint256 token);

    address public soluTokenAddress;
    constructor (address _soluTokenAddres) public {
        soluTokenAddress = _soluTokenAddres;
    }

    function _SetCrowdsaleStage(uint _stage) private {
        if(uint(ICOStage.PreICO) == _stage) {
            stage = ICOStage.PreICO;
        } else if (uint(ICOStage.SeedICO) == _stage) {
            stage = ICOStage.SeedICO;
        } else if(uint(ICOStage.FinalSale) == _stage) {
            stage = ICOStage.FinalSale;
            tokenToSellInFinalSale = tokenToSellInPreICO + tokenToSellInSeedICO;
        }

        if(stage == ICOStage.PreICO) {
            rate = 312500;
        } else if (stage == ICOStage.SeedICO) {
            rate = 156250;
        } else if (stage == ICOStage.FinalSale) {
            rate = 78125;
        }
    }

    function updateState(uint _stage) public onlyOwner {
        _SetCrowdsaleStage(_stage);
    }

    function setICOCompleted(bool complete) private {
        isICOCompleted = complete;
    }

    function buy() public payable {
        require(!isICOCompleted, "ICO is Completed");
        require(msg.value > 0, "Amount must be Greater than ZERO");
        
        uint256 tokenToBuy = msg.value * rate;
        
        if(stage == ICOStage.PreICO){
            require((tokenToSellInPreICO - tokenToBuy) >= 0, "PreICO Limit Exceed");
        } else if(stage == ICOStage.SeedICO){
            require((tokenToSellInSeedICO - tokenToBuy) >= 0, "SeedICO Limit Exceed");
        } else if(stage == ICOStage.FinalSale) {
            require((tokenToSellInFinalSale - tokenToBuy) >= 0, "Not enough Token");
        }
        
        IERC20 soluTokenContract = IERC20(soluTokenAddress);
        bool test = soluTokenContract.transfer(msg.sender, tokenToBuy);
        require(test,"Something went wrong, Token not Transffered");
        emit BuyToken(msg.sender, msg.value, tokenToBuy);
        
        if(stage == ICOStage.PreICO){
            tokenToSellInPreICO -= tokenToBuy;
        } else if(stage == ICOStage.SeedICO){
            tokenToSellInSeedICO -= tokenToBuy;
        }
        
        if(stage == ICOStage.PreICO && (tokenToSellInPreICO == 0 || tokenToSellInPreICO < rate)) {
            _SetCrowdsaleStage(uint(ICOStage.SeedICO));
        } else if(stage == ICOStage.SeedICO && (tokenToSellInSeedICO == 0 || tokenToSellInSeedICO < rate)){
            _SetCrowdsaleStage(uint(ICOStage.FinalSale));
        } else if(stage == ICOStage.FinalSale && (tokenToSellInFinalSale == 0 || tokenToSellInFinalSale < rate)){
            setICOCompleted(true);
        }
        
    }
}
