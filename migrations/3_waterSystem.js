let WaterGoverning = artifacts.require("./WaterGoverning.sol");
let WaterVouchers = artifacts.require("./WaterVouchers.sol");
var HouseholdMeters = artifacts.require("./HouseholdMeters.sol");
let PriceEstimator = artifacts.require("./PriceEstimator.sol");

module.exports = async function (deployer) {
    await deployer.deploy(HouseholdMeters);
    let HouseholdMetersInstance = await HouseholdMeters.deployed();

    await deployer.deploy(WaterVouchers);
    let WaterVouchersInstance = await WaterVouchers.deployed();

    await deployer.deploy(WaterGoverning, WaterVouchersInstance.address);
    let WaterGoverningInstance = await WaterGoverning.deployed();

    await deployer.deploy(PriceEstimator, HouseholdMetersInstance.address, WaterVouchersInstance.address);
    let PriceEstimatorInstance = await PriceEstimator.deployed();

    await WaterVouchersInstance.setWaterGoverningContractAddress(WaterGoverningInstance.address);
    await WaterVouchersInstance.setPriceEstimatorContractAddress(PriceEstimatorInstance.address);

    await WaterVouchersInstance.addIntermediary("0x627306090abaB3A6e1400e9345bC60c78a8BEf57");

    await WaterVouchersInstance.purchaseVoucher("1", "0xf17f52151EbEF6C7334FAD080c5704D77216b732", 13000);
};