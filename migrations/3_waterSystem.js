let WaterGoverning = artifacts.require("./WaterGoverning.sol");
let WaterVouchers = artifacts.require("./WaterVouchers.sol");

module.exports = async function (deployer) {
    await deployer.deploy(WaterVouchers);
    let WaterVouchersInstance = await WaterVouchers.deployed();

    await deployer.deploy(WaterGoverning, WaterVouchersInstance.address);
    let WaterGoverningInstance = await WaterGoverning.deployed();

    await WaterVouchersInstance.setWaterGoverningContractAddress(WaterGoverningInstance.address);
};