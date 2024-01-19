// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract InsuranceProtocol {

    uint public premiumPrice; // Monthly insurance premium price

    struct Client {
        uint validEnd;     // Timestamp of the end of the current insurance period
        uint lastClaimed;  // Timestamp of the last insurance claim
    }

    mapping(address => Client) public clients;

    // Custom errors
    string constant ERR_ACTIVE_PREMIUM_AVAILABLE = "Active premium already available";
    string constant ERR_INSUFFICIENT_AMOUNT = "Insufficient amount";
    string constant ERR_LAST_CLAIMED = "Last claim happened this year";
    string constant ERR_AMOUNT_EXCEEDS = "Claim amount exceeds 2 years premium";
    string constant ERR_INSUFFICIENT_FUNDS = "Insufficient funds to send the user";

    /**
     * @dev Constructor to initialize the insurance protocol with premium price.
     * @param _premiumPrice The monthly insurance premium price.
     */
    constructor(uint _premiumPrice) payable{
        premiumPrice = _premiumPrice;
    }

    /**
     * @dev Function for a wallet owner to pay the monthly insurance premium.
     */
    function payMonthlyPremium() external payable {
        Client storage clientData = clients[msg.sender];

        // Check if an active premium is already available
        require(block.timestamp >= clientData.validEnd, ERR_ACTIVE_PREMIUM_AVAILABLE);

        // Check if the sent amount is sufficient
        require(msg.value >= premiumPrice, ERR_INSUFFICIENT_AMOUNT);

        // Set the end of the current insurance period to 30 days from now
        clientData.validEnd = block.timestamp + 30 days;
    }

    /**
     * @dev Function for a wallet owner to pay the yearly insurance premium.
     */
    function payYearlyPremium() external payable {
        Client storage clientData = clients[msg.sender];

        // Check if an active premium is already available
        require(block.timestamp >= clientData.validEnd, ERR_ACTIVE_PREMIUM_AVAILABLE);

        // Check if the sent amount is equal to the yearly premium
        require(msg.value == (premiumPrice * 12 * 10) / 9, ERR_INSUFFICIENT_AMOUNT);

        // Set the end of the current insurance period to 365 days from now
        clientData.validEnd = block.timestamp + 365 days;
    }

    /**
     * @dev Function for a wallet owner to claim insurance.
     * @param _value The amount to be claimed.
     */
    function claimInsurance(uint _value) external {
        Client storage clientData = clients[msg.sender];

        // Check if a claim has been made within the last year
        require(block.timestamp > clientData.lastClaimed + 365 days, ERR_LAST_CLAIMED);

        // Check if the claimed value exceeds twice the yearly premium
        require(_value <= premiumPrice * 12 * 2, ERR_AMOUNT_EXCEEDS);

        // Check if there are sufficient funds in the contract to send to the user
        require(address(this).balance >= _value, ERR_INSUFFICIENT_FUNDS);

        // Update the last claimed timestamp and transfer the claimed amount to the user
        clientData.lastClaimed = block.timestamp;
        payable(msg.sender).transfer(_value);
    }

    /**
     * @dev Function to get the current premium price.
     * @return The monthly insurance premium price.
     */
    function getPremiumPrice() external view returns (uint) {
        return premiumPrice;
    }

    /**
     * @dev Function to get the client's insurance details.
     * @return The end timestamp of the current insurance period and the last claimed timestamp.
     */
    function getClientDetails(address _client) external view returns (uint, uint) {
        return (clients[_client].validEnd, clients[_client].lastClaimed);
    }
}
