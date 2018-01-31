const HouseholdMeters = artifacts.require("./HouseholdMeters.sol");
const PriceEstimator = artifacts.require("./PriceEstimator.sol");
const WaterVoucher = artifacts.require("./WaterVouchers.sol");
const util = require('./util');
const expectThrow = util.expectThrow;

contract('PriceEstimator', function (accounts) {
    const _owner = accounts[0];
    const _notOwner = accounts[1];

    const _householdMembers = 4;
    const _householdMembersUpdate = 6;

    const _householdMeter = "0x638cdecbdb9af6f7bc9b9415633fb42be0f89ad8";
    const _householdMeterUpdate = "0x638cdecbdb9af6f7bc9b9415633fb42be0f89ad9";

    const _admin1 = accounts[2];
    const _admin2 = accounts[3];

    const _liters1 = 4000;
    const _liters2 = 10000;
    const _liters3 = 30000;
    const _liters4 = 60000;

    const _price1 = 456;
    const _price2 = 1775;
    const _price3 = 4153;
    const _price4 = 23859;

    let HouseholdMetersContract;
    let PriceEstimatorContract;
    let WaterVoucherContract;

    describe("Estimate correct prices", () => {
        beforeEach(async function () {
            HouseholdMetersContract = await HouseholdMeters.new({
                from: _owner
            });

            WaterVoucherContract = await WaterVoucher.new({
                from: _owner
            });

            PriceEstimatorContract = await PriceEstimator.new(HouseholdMetersContract.address, WaterVoucherContract.address, {
                from: _owner
            });

            await HouseholdMetersContract.addAdmin(_admin1);
            await HouseholdMetersContract.addHouseholdMeter(_householdMeter, _householdMembers, {
                from: _admin1
            });
        });

        it("should estimate price for less than 6000 liters", async function () {
            let result = await PriceEstimatorContract.estimate(_householdMeter, _liters1);
            let expectedResult = (_liters1 / 1000) * _price1;
            assert(result.eq(expectedResult), "The price was not correct");
        });

        it("should estimate price for less than 10500 liters", async function () {
            let result = await PriceEstimatorContract.estimate(_householdMeter, _liters2);
            let expectedResult = (_liters2 / 1000) * _price2;
            assert(result.eq(expectedResult), "The price was not correct");

        });

        it("should estimate price for less than 30000 liters", async function () {
            let result = await PriceEstimatorContract.estimate(_householdMeter, _liters3);
            let expectedResult = (_liters3 / 1000) * _price3;
            assert(result.eq(expectedResult), "The price was not correct");
        });

        it("should estimate price for mote than 50000 liters", async function () {
            let result = await PriceEstimatorContract.estimate(_householdMeter, _liters4);
            let expectedResult = (_liters4 / 1000) * _price4;
            assert(result.eq(expectedResult), "The price was not correct");
        });
        // TODO Write more tests
        // require(_meter != address(0));
        // require(_liters > 1000);
    });
});