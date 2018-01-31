pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./WaterGoverning.sol";
import "./PriceEstimator.sol";

contract WaterVouchers is Ownable {
    address public waterGoverningContractAddress;
    address public priceEstimatorContractAddress;

    struct Intermediary {
        bool isActive;
        uint256 intermediariesArrayIndex;
    }
    address[] public intermediariesAddresses;
    mapping(address => Intermediary) public intermediaries;

    struct Voucher {
        address issuer;
        uint256 liters;
        address meter;
        uint256 totalPrice;
        uint256 timestamp;
        uint256 voucherIdsArrayIndex;
        bool isActive;
    }
    bytes32[] public voucherIds;
    mapping(bytes32 => Voucher) public vouchers;
    mapping(address => bytes32[]) public meterVouchers;

    event LogAddIntermediary(address _newIntermediary);
    event LogRemoveIntermediary(address _intermediaryToRemove);
    event LogSubmitVoucher(address _issuer, address _meter, bytes32 _voucherId, uint256 _liters);

    modifier onlyIntermediary() {
        require(intermediaries[msg.sender].isActive);
        _;
    }

    modifier onlyNotExistingIntermediary(address _intermediary) {
        require(!intermediaries[_intermediary].isActive);
        _;
    }

    modifier onlyExistingIntermediary(address _intermediary) {
        require(intermediaries[_intermediary].isActive);
        _;
    }

    modifier onlyNotExistingVoucher(bytes32 _voucher) {
        require(!vouchers[_voucher].isActive);
        _;
    }

    modifier onlyExistingVoucher(bytes32 _voucher) {
        require(vouchers[_voucher].isActive);
        _;
    }

    function WaterVouchers(address _priceEstimatorContractAddress) public {
        priceEstimatorContractAddress = _priceEstimatorContractAddress;
    }

    // TODO 
    function getLastVoucherLiters(address _meter) public constant returns(uint256 liters) {
        // bytes32[] voucherIds = meterVouchers[_meter];
        // bytes32 voucherId = voucherIds[0];
        return 100; //vouchers[voucherId].liters;
    }

    function setWaterGoverningContractAddress(address _waterGoverningContractAddress) public onlyOwner returns(bool success) {
        waterGoverningContractAddress = _waterGoverningContractAddress;
        return true;
    }

    function addIntermediary(address _newIntermediary) 
        public onlyOwner onlyNotExistingIntermediary(_newIntermediary) returns(bool success) 
    {
        require(_newIntermediary != address(0));

        intermediaries[_newIntermediary] = Intermediary({
            isActive: true,
            intermediariesArrayIndex: intermediariesAddresses.length
        });
        intermediariesAddresses.push(_newIntermediary);

        LogAddIntermediary(_newIntermediary);

        return true;
    }

    function removeIntermediary(address _intermediaryToRemove) 
        public onlyOwner onlyExistingIntermediary(_intermediaryToRemove) returns(bool success) 
    {
        require(_intermediaryToRemove != address(0));
        
        address lastId = intermediariesAddresses[intermediariesAddresses.length-1];
        intermediariesAddresses[intermediaries[_intermediaryToRemove].intermediariesArrayIndex] = lastId;
        intermediariesAddresses.length--;
        intermediaries[lastId].intermediariesArrayIndex = intermediaries[_intermediaryToRemove].intermediariesArrayIndex;
        intermediaries[_intermediaryToRemove].isActive = false;

        LogRemoveIntermediary(_intermediaryToRemove);

        return true;
    }

    function submitVoucher(bytes32 _voucherId, address _meter, uint256 _liters) 
        public onlyIntermediary onlyNotExistingVoucher(_voucherId) returns(bool success) 
    {
        require(_voucherId.length != 0);
        require(_meter != address(0));
        require(_liters > 0);

        PriceEstimator priceEstimatorContract = PriceEstimator(priceEstimatorContractAddress);

        vouchers[_voucherId] = Voucher({
            issuer: msg.sender,
            liters: _liters,
            meter: _meter,
            totalPrice: priceEstimatorContract.estimate(_meter, _liters),
            timestamp: now,
            voucherIdsArrayIndex: voucherIds.length,
            isActive: true
        });
        
        voucherIds.push(_voucherId);
        meterVouchers[_meter].push(_voucherId);

        WaterGoverning waterGoverning = WaterGoverning(waterGoverningContractAddress);
        waterGoverning.addLiters(_meter, _liters);
        
        LogSubmitVoucher(msg.sender, _meter, _voucherId, _liters);

        return true;
    }
}