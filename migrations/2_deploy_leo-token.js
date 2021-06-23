const LeoToken = artifacts.require("LEO");
const AddressLib = artifacts.require('Address')
const SafeMathLib = artifacts.require('SafeMath')
const UtilsLib = artifacts.require('Utils')

module.exports = async function (deployer, network, accounts) {
  // Deploy AddressLib & SafeMathLib
  deployer.deploy(AddressLib);
  deployer.deploy(SafeMathLib);

  // Link safeMathLib and deploy UtilsLib
  deployer.link(SafeMathLib, UtilsLib);
  deployer.deploy(UtilsLib);

  // LeoToken libs
  deployer.link(SafeMathLib, LeoToken);
  deployer.link(AddressLib, LeoToken);
  deployer.link(UtilsLib, LeoToken);

  // Deploy contracts
  const instance = await deployer.deploy(LeoToken);
  console.log('Deployed', instance.address);
};
