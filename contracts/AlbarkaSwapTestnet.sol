// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract AlbarkaSwapTestnet {
    IERC20 public immutable usdt;
    address public immutable owner;

    // Test rate:
    // 1 ETH = 1,000 USDT
    uint256 public constant USDT_PER_ETH = 1000;
    uint256 public constant USDT_DECIMALS = 6;

    event EthToUsdtSwapped(
        address indexed user,
        uint256 ethAmount,
        uint256 usdtAmount
    );

    event UsdtToEthSwapped(
        address indexed user,
        uint256 usdtAmount,
        uint256 ethAmount
    );

    event LiquidityDeposited(
        address indexed provider,
        uint256 ethAmount,
        uint256 usdtAmount
    );

    event LiquidityWithdrawn(
        address indexed owner,
        uint256 ethAmount,
        uint256 usdtAmount
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address usdtAddress) {
        require(usdtAddress != address(0), "Invalid USDT address");

        usdt = IERC20(usdtAddress);
        owner = msg.sender;
    }

    receive() external payable {}

    function swapEthToUsdt() external payable {
        require(msg.value > 0, "ETH amount must be greater than zero");

        uint256 usdtAmount =
            (msg.value * USDT_PER_ETH * 10 ** USDT_DECIMALS) /
            1 ether;

        require(
            usdt.balanceOf(address(this)) >= usdtAmount,
            "Insufficient USDT liquidity"
        );

        require(
            usdt.transfer(msg.sender, usdtAmount),
            "USDT transfer failed"
        );

        emit EthToUsdtSwapped(
            msg.sender,
            msg.value,
            usdtAmount
        );
    }

    function swapUsdtToEth(uint256 amountUsdt) external {
        require(
            amountUsdt > 0,
            "USDT amount must be greater than zero"
        );

        uint256 ethAmount =
            (amountUsdt * 1 ether) /
            (USDT_PER_ETH * 10 ** USDT_DECIMALS);

        require(
            ethAmount > 0,
            "USDT amount too small"
        );

        require(
            address(this).balance >= ethAmount,
            "Insufficient ETH liquidity"
        );

        require(
            usdt.transferFrom(
                msg.sender,
                address(this),
                amountUsdt
            ),
            "USDT transferFrom failed"
        );

        (bool sent, ) = payable(msg.sender).call{
            value: ethAmount
        }("");

        require(sent, "ETH transfer failed");

        emit UsdtToEthSwapped(
            msg.sender,
            amountUsdt,
            ethAmount
        );
    }

    function depositUsdt(uint256 amount) external {
        require(
            amount > 0,
            "Amount must be greater than zero"
        );

        require(
            usdt.transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "USDT deposit failed"
        );

        emit LiquidityDeposited(
            msg.sender,
            0,
            amount
        );
    }

    function withdrawUsdt(
        uint256 amount,
        address to
    ) external onlyOwner {
        require(
            to != address(0),
            "Invalid address"
        );

        require(
            usdt.transfer(to, amount),
            "USDT withdrawal failed"
        );

        emit LiquidityWithdrawn(
            msg.sender,
            0,
            amount
        );
    }

    function withdrawEth(
        uint256 amount,
        address payable to
    ) external onlyOwner {
        require(
            to != address(0),
            "Invalid address"
        );

        require(
            address(this).balance >= amount,
            "Insufficient ETH"
        );

        (bool sent, ) = to.call{value: amount}("");

        require(
            sent,
            "ETH withdrawal failed"
        );

        emit LiquidityWithdrawn(
            msg.sender,
            amount,
            0
        );
    }

    function getUsdtBalance()
        external
        view
        returns (uint256)
    {
        return usdt.balanceOf(address(this));
    }

    function getEthBalance()
        external
        view
        returns (uint256)
    {
        return address(this).balance;
    }
}
