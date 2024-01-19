// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ColateralProtocol {
    address public owner;
    address public factory;
    address public loanToken;
    uint256 public collateralAmount;
    uint256 public loanAmount;
    uint256 public lastCollateralCheckTimestamp;
    bool public loanLiquidated;
    bool public loanRepaid;
    event CollateralCheck(address indexed owner, uint256 currentCollateralValue);
    string constant ERR_ONLY_OWNER = "Only owner allowed";

    constructor(
        uint256 _collateralAmount,
        uint256 _loanAmount,
        address _client,
        address _factory,
        address _loanToken
    ) {
        owner = _client;
        collateralAmount = _collateralAmount;
        loanAmount = _loanAmount;
        lastCollateralCheckTimestamp = block.timestamp;
        factory = _factory;
        loanToken = _loanToken;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, ERR_ONLY_OWNER);
        _;
    }

    function checkCollateralValue() external onlyOwner {
        require(block.timestamp >= lastCollateralCheckTimestamp + 30 days, "CollateralValueCanBeCheckedOncePerMonth");
        bool liquidate = isPriceDropGreaterThan20Percent(getEthPrice());
        if (liquidate) {
            loanLiquidated = true;
        }
        lastCollateralCheckTimestamp = block.timestamp;
        emit CollateralCheck(owner, getEthPrice());
    }

    function getLoanAmount() external view returns (uint256) {
        return loanAmount;
    }

    function repayLoan(uint256 _repaymentAmount) external {
        require(loanAmount <= _repaymentAmount, "ExcessPaymentAmount");
        require(!loanLiquidated, "LoanAlreadyLiquidated");
        IERC20(loanToken).transferFrom(msg.sender, factory, _repaymentAmount);
        loanAmount -= _repaymentAmount;
        if (loanAmount == 0) {
            loanRepaid = true;
            payable(owner).transfer(collateralAmount);
        }
    }

    receive() external payable {}

    function getEthPrice() internal pure returns (uint256) {
        return 1500;
    }

    function isPriceDropGreaterThan20Percent(uint256 currentPrice) public view returns (bool) {
        uint256 initialCollateralPrice = (loanAmount * 1500) / (1000 * 10 ** 18);
        uint256 priceDropPercentage = ((initialCollateralPrice - currentPrice) * 100) / initialCollateralPrice;
        return priceDropPercentage >= 20;
    }
}
