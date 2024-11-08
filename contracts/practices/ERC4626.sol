// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC4626} from "./IERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title 简易版的ERC4626 合约,具体请查看 openzeppelin
 * @dev   
 */
contract ERC4626 is ERC20, IERC4626 {

     /*//////////////////////////////////////////////////////////////
                            状态变量
     //////////////////////////////////////////////////////////////*/

    ERC20 private immutable _asset;
    uint8 private immutable _decimals;

    constructor(
        ERC20 asset_,
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        _asset = asset_;
        _decimals = asset_.decimals();
    }

    function asset() public view virtual returns (address) {
        return address(_asset);
    }

    function decimals() public view virtual override(IERC20Metadata, ERC20)  returns (uint8) {
        return _decimals;
    }

    function deposit(uint assets, address receiver) public virtual returns (uint shares) {
        shares = previewDeposit(assets);

        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function mint(uint shares, address receiver) public virtual returns (uint assets) {
        assets = previewMint(shares);

        _asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function withdraw(uint assets, address receiver, address owner) public virtual returns (uint shares) {
        shares = previewWithdraw(assets);

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function redeem(uint shares, address receiver, address owner) public virtual returns (uint assets) {
        assets = previewRedeem(shares);

        if (msg.sender != owner) {
            _spendAllowance(owner, msg.sender, shares);
        }

        _burn(owner, shares);
        _asset.transfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }

    function totalAssets() public view virtual returns (uint) {
        return _asset.balanceOf(address(this));
    }

    function convertToShares(uint assets) public view virtual returns (uint) {
        uint supply = totalSupply();
//        如果supply 为0 ,那么1:1 铸造金库份额
//        如果supply 不为0, 那么按比例铸造
        return supply ==0 ? assets : assets * supply / totalAssets();
    }

    function convertToAssets(uint shares) public view virtual returns (uint) {
        uint supply = totalAssets();
        return supply ==0 ? shares : shares * totalAssets() / supply;
    }

    function previewDeposit(uint assets) public view virtual returns (uint) {
        return convertToShares(assets);
    }

    function previewMint(uint shares) public view virtual returns (uint) {
        return convertToAssets(shares);
    }

    function previewWithdraw(uint assets) public view virtual returns (uint) {
        return convertToShares(assets);
    }

    function previewRedeem(uint shares) public view virtual returns (uint) {
        return convertToAssets(shares);
    }

    function maxDeposit(address) public view virtual returns (uint) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint) {
        return type(uint256).max;
    }

    function maxWithdraw(address) public view virtual returns (uint) {
        return type(uint256).max;
    }

    function maxRedeem(address) public view virtual returns (uint) {
        return type(uint256).max;
    }


}
