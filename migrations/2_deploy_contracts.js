var SoluToken = artifacts.require('SoluToken.sol');
var SoluTokenSale = artifacts.require('SoluTokenSale.sol');

module.exports = async function(deployer){
    let addr = await web3.eth.getAccounts();
    await deployer.deploy(SoluToken, 1000000000);
    let instance = await SoluToken.deployed();
    await deployer.deploy(SoluTokenSale, instance.address);
    await instance.transfer(SoluTokenSale.address, 1000000000);
}