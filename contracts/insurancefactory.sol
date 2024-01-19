// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./insurance.sol";
import "./collateral.sol";

contract InsuranceProtocolFactory is ERC20, Ownable {
        // State variables
    mapping(address => InsuranceProtocol) public insurancePools;
    mapping(address => ColateralProtocol) public collateralPools;
    address public loanToken;
    

    address[] public insurancePoolAddresses;
    address[] public collateralPoolAddresses;
    address public admin;
    // Modifier to check if the provided pool address is valid
    modifier isValidPool(InsuranceProtocol pool) {
        require(address(pool) != address(0), "Invalid pool address");
        _;
    }

    // Custom error
    string constant ERR_ONLY_ADMIN = "Only admin allowed";
    modifier onlyAdmin() {
        require(msg.sender == admin, ERR_ONLY_ADMIN);
        _;
    }

    // Constructor to set the admin and loan token address
    constructor(address _admin) payable ERC20("TITAN", "TIT") Ownable(_admin) {
        admin = _admin;
        loanToken = 0x7fb31c05B41E10c3c4f05eEe7d3401fDb96b3f40;
        transferOwnership(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
        _mint(msg.sender, 100000 * 10 ** 18);
    }

   

    // Function to create a new insurance pool
    function createInsurancePool(uint _premium) external payable {
        InsuranceProtocol newPool = new InsuranceProtocol(_premium);
        insurancePools[msg.sender] = newPool;
        insurancePoolAddresses.push(address(newPool));
    }

    // Function to create a new collateral pool
    function createCollateralPool() external payable {
        // Calculate the Ether value based on the provided value and current Ether price

        uint ethValue = (msg.value * getEthPrice()) / 10 ** 18;
   
        // Calculate the loan amount based on the collateral value
        uint loanAmount = (ethValue * (1000 * 10 ** 18)) / 1500;

        // Create a new collateral pool
        ColateralProtocol newPool = new ColateralProtocol(
            msg.value,
            loanAmount,
            msg.sender,
            address(this),
            loanToken
        );

        // Store the collateral pool and its address
        collateralPools[msg.sender] = newPool;
        collateralPoolAddresses.push(address(newPool));

        // Transfer the loan amount in tokens to the pool creator
        _transfer(owner(),msg.sender, loanAmount);
        // Transfer the provided Ether value to the collateral pool
        payable(address(newPool)).transfer(msg.value);
        
    }

    // Function to get the list of insurance pool addresses
    function getInsurancePools() external view returns (address[] memory) {
        return insurancePoolAddresses;
    }

    // Function to get the list of collateral pool addresses
    function getCollateralPools() external view returns (address[] memory) {
        return collateralPoolAddresses;
    }

    // Function to get the current Ether price
    function getEthPrice() internal pure returns (uint) {
        // In a real application, an oracle implementation should be used to fetch the current Ether price.
        return 1500;
    }

    // Function to ensure that only the admin can call certain functions

}