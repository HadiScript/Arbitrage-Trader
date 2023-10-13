// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

// receive prices of the different assets trade of outisde block that centrilize
contract Oracle {
    struct Result {
        bool exist;
        uint256 payload;
        address[] approvedBy;
    }

    mapping(bytes32 => Result) private results;

    address[] public validator;

    constructor(address[] memory _validator) {
        validator = _validator;
    }

    function feedData(bytes32 _dataKey, uint256 _payload)
        external
        onlyValidator
    {
        address[] memory approvedBy = new address[](1);
        approvedBy[0] = msg.sender;
        require(
            results[_dataKey].exist == false,
            "this data was already imported"
        );

        results[_dataKey] = Result(true, _payload, approvedBy);
    }

    function approvedData(bytes32 _dataKey) external onlyValidator {
        Result storage result = results[_dataKey];

        require(result.exist == true, "Cant approve non existing data");
        for (uint256 i = 0; i < result.approvedBy.length; i++) {
            require(
                result.approvedBy[i] != msg.sender,
                "can not approve same data twice"
            );
        }

        result.approvedBy.push(msg.sender);
    }

    //call by arbitrage contract
    function getData(bytes32 _dataKey) external view returns (Result memory) {
        return results[_dataKey];
    }

    modifier onlyValidator() {
        bool isValidator = false;
        for (uint256 i = 0; i < validator.length; i++) {
            if (validator[i] == msg.sender) {
                isValidator = true;
            }
        }

        require(isValidator == true, "Only Validator");
        _;
    }
}
