// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

// decentralize exchange
contract Dex {
    mapping(string => uint256) private prices;

    // return latest price of any asset
    function getPrice(string calldata _sticker)
        external
        view
        returns (uint256)
    {
        return prices[_sticker];
    }

    // buy or sale any erc token
    function Buy(
        string calldata _sticker,
        uint256 _amount,
        uint256 _price
    ) external {
        // buy erc20 tokens
    }

    function Sale(
        string calldata _sticker,
        uint256 _amount,
        uint256 _price
    ) external {
        // sale erc20 tokens
    }
}
