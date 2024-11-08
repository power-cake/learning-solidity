// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title https://eips.ethereum.org/EIPS/eip-4626[ERC-4626].
 * @dev   ERC4626 "代币化金库标准"的接口合约
 */
interface IERC4626 is IERC20, IERC20Metadata {
    /*//////////////////////////////////////////////////////////////
                                 事件
    //////////////////////////////////////////////////////////////*/
//    存款触发
    event Deposit(address indexed sender, address indexed owner, uint assets, uint shares);

//    取款触发
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint assets,
        uint share
    );

    /*//////////////////////////////////////////////////////////////
                           元数据
   //////////////////////////////////////////////////////////////*/

    /**
     * @dev 返回金库基础资产代币地址, 必须说erc20代币地址
     */
    function asset() external view returns (address assetTokenAddress);

    /*//////////////////////////////////////////////////////////////
                       存款/提款逻辑
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev 存款函数:用户向金库存入 assets 单位的基础资产, 然后合约铸造 shares 单位的金库额度给receiver地址
     */
    function deposit(uint assets, address receiver) external returns (uint shares);

    /**
     * @dev 铸造函数: 用户需要存入 assets的基础资产 铸造出assets的份额
     */
    function mint(uint shares, address receiver) external returns (uint assets) ;

    /**
     * @dev  提款函数: owenr 地址销毁 shares 单位的金额额度, 然后合约将assets的基础资产发给 receiver
     */
    function withdraw(uint assets, address receiver, address owner) external returns (uint shares);

    /**
     * @dev 赎回函数: owenr 地址销毁 shares 数量的金库份额,然后合约将assets 单位的基础资产 发给 receiver 地址
     */
    function redeem(uint shares, address receiver, address owner) external returns (uint assets);

     /*//////////////////////////////////////////////////////////////
                            会计逻辑
     //////////////////////////////////////////////////////////////*/

    /**
     * @dev 返回金库中管理的基础资产代币总额
     * — 要包含利息
     * - 要包含费用
     */
    function totalAssets() external view returns (uint totalManagedAssets);

    /**
     * @dev 返回利用一定数额基础资产可以换取金额额度
     * - 不包含费用
     * - 不包含划点
     * - 不能revert
     */
    function convertToShares(uint assets) external view returns (uint shares);

    /**
     * @dev 返回利用一定数量金库额度可以换取的基础资产
     * - 不包含费用
     * - 不包含滑点
     * - 不能revert
     */
    function convertToAssets(uint shares) external view returns (uint assets);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟存款一定数额的基础资产能够获得的金库额度
     * - 返回值要接近且不大于在同一交易进行存款得到的金额额度
     * - 不要考虑 maxDeposit 等限制,假设用户的存款交易会成功
     * - 要考虑费用
     * - 不要revert
     */
    function previewDeposit(uint assets) external view returns (uint shares);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟铸造 shares 数额的金库额度需要存款的基础资产数量
     * - 返回值要接近且不小于在同一交易进行铸造一定数额金库额度所需的存款数量
     * - 不要考虑 maxMint 等限制，假设用户的存款交易会成功
     * - 要考虑费用
     * - 不能revert
     */
    function previewMint(uint shares) external view  returns (uint assets);

    /**
     * @dev 用于链上和链下用户在当前链上环境模拟提款 assets 数额的基础资产需要赎回的金库份额
     * - 返回值要接近且不大于在同一交易进行提款一定数额基础资产所需赎回的金库份额
     * - 不要考虑 maxWithdraw 等限制，假设用户的提款交易会成功
     * - 要考虑费用
     * - 不能revert
     */
    function previewWithdraw(uint assets) external view returns (uint shares);

    /**
    * @dev 用于链上和链下用户在当前链上环境模拟销毁 shares 数额的金库额度能够赎回的基础资产数量
     * - 返回值要接近且不小于在同一交易进行销毁一定数额的金库额度所能赎回的基础资产数量
     * - 不要考虑 maxRedeem 等限制，假设用户的赎回交易会成功
     * - 要考虑费用
     * - 不能revert.
     */
    function previewRedeem(uint shares) external view  returns (uint assets);

     /*//////////////////////////////////////////////////////////////
                            存款/提款限额逻辑
     //////////////////////////////////////////////////////////////*/

    /**
     * @dev 返回某个用户地址单次存款可存的最大基础资产数额。
     * - 如果有存款上限，那么返回值应该是个有限值
     * - 返回值不能超过 2 ** 256 - 1
     * - 不能revert
     */
    function maxDeposit(address receiver) external view returns (uint maxAssets);

    /**
     * @dev 返回某个用户地址单次铸造可以铸造的最大金库额度
     * - 如果有铸造上限，那么返回值应该是个有限值
     * - 返回值不能超过 2 ** 256 - 1
     * - 不能revert
     */
    function maxMint(address receiver) external view returns (uint maxShares);

    /**
   * @dev 返回某个用户地址单次取款可以提取的最大基础资产额度
     * - 返回值应该是个有限值
     * - 不能revert
     */
    function maxWithdraw(address owner) external view returns (uint maxAssets);

    /**
    * @dev 返回某个用户地址单次赎回可以销毁的最大金库额度
     * - 返回值应该是个有限值
     * - 如果没有其他限制，返回值应该是 balanceOf(owner)
     * - 不能revert
     */
    function maxRedeem(address owner) external view returns (uint maxShares);
}