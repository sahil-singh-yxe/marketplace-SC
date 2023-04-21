const contract = artifacts.require('MarketplaceToken');
module.exports = function(deployer) {
    deployer.deploy(contract);
    // Additional contracts can be deployed here
};