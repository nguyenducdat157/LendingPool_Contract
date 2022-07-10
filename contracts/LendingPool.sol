//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;
import "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import "@aave/protocol-v2/contracts/misc/AaveProtocolDataProvider.sol";
import "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/SafeERC20.sol";

interface IWETHGateway {
    function depositETH(
        address lendingPool,
        address onBehalfOf,
        uint16 referralCode
    ) external payable;

    function withdrawETH(
        address lendingPool,
        uint256 amount,
        address onBehalfOf
    ) external;
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function approve(address guy, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}

interface CEth {
    function balanceOf(address) external view returns (uint256);

    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function balanceOfUnderlying(address) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function repayBorrow() external payable;

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

interface CErc20 {
    function balanceOf(address) external view returns (uint256);

    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function balanceOfUnderlying(address) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
}

interface Comptroller {
    function markets(address)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function closeFactorMantissa() external view returns (uint256);

    function liquidationIncentiveMantissa() external view returns (uint256);

    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);
}

interface PriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}

contract LendingPool {
    using SafeERC20 for IERC20;

    // ILendingPoolAave public constant AAVE =
    //     ILendingPoolAave(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);
    ILendingPool public AAVE =
        ILendingPool(0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe);

    AaveProtocolDataProvider public dataProvider =
        AaveProtocolDataProvider(0x3c73A5E5785cAC854D468F727c606C07488a29D6);

    IERC20 public constant DAI_AAVE =
        IERC20(0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD);
    IWETHGateway public constant WETH_GATEWAY =
        IWETHGateway(0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70);
    IERC20 public constant A_WETH =
        IERC20(0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347);

    CEth public constant C_ETH =
        CEth(0x41B5844f4680a8C38fBb695b7F9CFd1F64474a72);

    CErc20 public constant C_DAI =
        CErc20(0xF0d0EB522cfa50B716B3b1604C4F0fA6f04376AD);

    IERC20 public constant DAI =
        IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);

    event MyLog(string, uint256);

    function depositAave() external payable {
        WETH_GATEWAY.depositETH{value: msg.value}(address(AAVE), msg.sender, 0);
    }

    function withdrawAave(uint256 amount) external {
        A_WETH.approve(address(WETH_GATEWAY), amount);
        WETH_GATEWAY.withdrawETH(address(AAVE), amount, msg.sender);
    }

    // function borrowAave(uint256 amount) external {
    //     AAVE.borrow(address(DAI_AAVE), amount, 2, 0, msg.sender);
    // }

    // function repayAave(uint256 amount) external returns (uint256) {
    //     return AAVE.repay(address(DAI_AAVE), amount, 2, msg.sender);
    // }

    function borrowAave(uint256 amount) external {
        AAVE.borrow(address(DAI_AAVE), amount, 1, 0, msg.sender);
        DAI_AAVE.safeTransfer(msg.sender, amount);
    }

    function repayAave(uint256 amount) external {
        uint256 allowance = DAI_AAVE.allowance(msg.sender, address(this));
        require(
            amount <= allowance,
            "amount must be less than or equal to allowance"
        );

        DAI_AAVE.safeTransferFrom(msg.sender, address(this), amount);

        DAI_AAVE.approve(address(AAVE), amount);

        AAVE.repay(address(DAI_AAVE), amount, 1, msg.sender);
    }

    // function depositCompound(uint256 amount) public returns (bool) {
    //     C_ETH.mint{value: amount, gas: 250000}();
    //     return true;
    // }

    function depositCompound() public payable returns (bool) {
        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = C_ETH.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = C_ETH.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        C_ETH.mint{value: msg.value, gas: 250000}();
        uint256 toMyWallet = C_ETH.balanceOf(address(this));
        C_ETH.transferFrom(address(this), msg.sender, toMyWallet);

        return true;
    }

    function withdrawCompound(uint256 amount, bool redeemType)
        public
        returns (bool)
    {
        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = C_ETH.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = C_ETH.redeemUnderlying(amount);
        }
        return true;
    }

    function borrowCompound(uint256 amount) public returns (bool) {
        C_DAI.borrow(amount);
        return true;
    }

    function repayCompound(uint256 amount) public returns (bool) {
        DAI.approve(address(C_DAI), amount);
        uint256 error = C_DAI.repayBorrow(amount);

        require(error == 0, "CErc20.repayBorrow Error");
        return true;
    }

    // This is needed to receive ETH when calling `redeemCEth`
    receive() external payable {}

    fallback() external payable {}
}
