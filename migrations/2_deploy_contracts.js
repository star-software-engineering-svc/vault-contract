const Strategy4BeltBlp = artifacts.require("Strategy4BeltBlp");
const UsdtVault = artifacts.require("UsdtVault");

module.exports = async function (deployer) {
  await deployer.deploy(Strategy4BeltBlp)
  await deployer.deploy(UsdtVault, Strategy4BeltBlp.address)
  instanceStrategy = await Strategy4BeltBlp.deployed()
  await instanceStrategy.setJar(UsdtVault.address)
  await instanceStrategy.addToWhiteList(UsdtVault.address)
};
