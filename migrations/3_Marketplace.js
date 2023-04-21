// 1. Import the Marketplace contract and the ERC20 contract
const Marketplace = artifacts.require("Marketplace");
const MyToken = artifacts.require("MarketplaceToken");

module.exports = function (deployer) {
  // 2. Deploy the ERC20 token contract
  deployer.deploy(MyToken).then(function() {
    // 3. Get the address of the deployed ERC20 token contract
    const tokenAddress = MyToken.address;
    // 4. Deploy the Marketplace contract with the address of the ERC20 token contract as a parameter
    return deployer.deploy(Marketplace, tokenAddress);
  });
};