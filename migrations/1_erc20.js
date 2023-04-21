const contract = artifacts.require('ERC20');
module.exports = function(deployer) {
    deployer.deploy(contract, "MyToken", "MTK");
    // Additional contracts can be deployed here
};