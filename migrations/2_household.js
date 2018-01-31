var HouseholdMeters = artifacts.require("./HouseholdMeters.sol");
let PriceEstimator = artifacts.require("./PriceEstimator.sol");

module.exports = async function (deployer) {
    await deployer.deploy(HouseholdMeters);
    let HouseholdMetersInstance = await HouseholdMeters.deployed();

    await deployer.deploy(PriceEstimator, HouseholdMetersInstance.address);
};