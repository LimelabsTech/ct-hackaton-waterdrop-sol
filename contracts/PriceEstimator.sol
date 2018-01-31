pragma solidity ^0.4.18;

import "./HouseholdMeters.sol";
import "./WaterVouchers.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

contract PriceEstimator {
    using SafeMath for uint256;
// TODO Make it upgradeble
    HouseholdMeters householdMetersContract;
    WaterVouchers waterVouchersContract;

    function PriceEstimator (address _householdMetersAddress, address _waterVoucherAddress) public {
        householdMetersContract = HouseholdMeters(_householdMetersAddress);
        waterVouchersContract = WaterVouchers(_waterVoucherAddress);
    }

    function getCurrentMonthLiters(address _meter, uint256 _toTimestamp) public view returns(uint256 liters) {

        // this.getCurrentMonthLiters(_meter, _fromTimestamp);
        // TODO Find all liters for past 30 days
        return waterVouchersContract.getLastVoucherLiters(_meter);
    }

    function estimate(address _meter, uint _liters) public view returns(uint256 price) {        
        require(_meter != address(0));
        require(_liters > 3000);
        require(_liters % 1000 == 0);

        uint256 householdSize = householdMetersContract.getHouseholdMembersCount(_meter);
        // TODO Sum up all liters used in the past 4 weeks
        // _liters += this.getCurrentMonthLiters(_meter, now - 4 weeks);

        if (_liters <= householdSize.mul(1500)) {
            return _liters.div(1000).mul(456); // R4.56
        }
        if (_liters <= householdSize.mul(2625)) {
            return _liters.div(1000).mul(1775); // R17.75
        }
        if (_liters <= householdSize.mul(5000)) {
            return _liters.div(1000).mul(2493); // R24.93
        }
        if (_liters <= householdSize.mul(8750)) {
            return _liters.div(1000).mul(4153); // R41.53
        }
        if (_liters <= householdSize.mul(12500)) {
            return _liters.div(1000).mul(7029); // R70.29
        } else {
            return _liters.div(1000).mul(23859); // R238.59
        }
    }
}