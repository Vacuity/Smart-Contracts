const VIOS = artifacts.require("VIOS");
const ATN = artifacts.require("ATN");

module.exports = function(deployer) {
  deployer.deploy(VIOS, "0x77325913D3a1628a1E751354DB99C1cF07bA30FC");
};
