
// SPDX-License-Identifier: UNLICENSED

import "contracts/dapp-30/Dex.sol";
import "contracts/dapp-30/Oracle.sol";

pragma solidity >=0.7.0 <0.9.0;

// 1 Arbitrage contract - execute the trade
// 2 Dex contract - buy and sale erc20 tokens
// 3 Oracle contract - able to rec data from outside and pass it out other contract

// admin contract
contract ArbitrageTrader {
    struct Asset {
        string name;
        address dex;
    }

    // in new version we do this in mapping ->
    // in previous version we were used bytes32
    mapping(string => Asset) public assets;

    address public admin;
    address public oracle;

    constructor() {
        admin = msg.sender;
    }

    function configureOracle(address _orcale) external onlyAdmin {
        oracle = _orcale;
    }

    // simple we will add Asset (Struct) to assets (mapping)
    function configureAssets(Asset[] calldata _assets) external onlyAdmin {
        for (uint256 i = 0; i < _assets.length; i++) {
            assets[_assets[i].name] = Asset(_assets[i].name, _assets[i].dex);
        }
    }

    // camparing price of dex and price of oracle asset
    function maybeTrade(string calldata _sticker, uint256 _date)
        external
        onlyAdmin
    {
        Asset storage asset = assets[_sticker];
        // address(0) means null
        require(asset.dex != address(0), "Doesnt exits this asset");

        // get latest price from oracle
        bytes32 dataKey = keccak256(abi.encodePacked(_sticker, _date));
        Oracle oracleContract = Oracle(oracle);
        Oracle.Result memory result = oracleContract.getData(dataKey);

        require(
            result.exist == true,
            "This result doesnot exist and doesnt trade"
        );

        require(
            result.approvedBy.length == 10,
            "not enough approvals for this trade"
        );

        // if there is price, trade of the dex

        Dex DexContract = Dex(asset.dex);
        uint256 price = DexContract.getPrice(_sticker);

        uint256 amount = 1 ether / price;

        if (price > result.payload) {
            DexContract.Sale(_sticker, amount, (99 * price) / 100);
        } else if (price < result.payload) {
            DexContract.Buy(_sticker, amount, (101 * price) / 100);
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }
}
