const { ethers } = require('hardhat');

async function main() {
    const InsuranceProtocol = await ethers.getContractFactory("InsuranceProtocol");
    const insuranceProtocol = await InsuranceProtocol.deploy(10);
    await insuranceProtocol.deployed();
    console.log("InsuranceProtocol deployed to:", insuranceProtocol.address);

    const InsuranceProtocolFactory = await ethers.getContractFactory("InsuranceProtocolFactory");
    const insuranceProtocolFactory = await InsuranceProtocolFactory.deploy("0x461d9eD7FE07F35F2ABC60C85ee8226446e855Aa");
    await insuranceProtocolFactory.deployed();
    console.log("InsuranceProtocolFactory deployed to:", insuranceProtocolFactory.address);

    const CollateralProtocol = await ethers.getContractFactory("ColateralProtocol");
    const collateralProtocol = await CollateralProtocol.deploy(20, 10, "0xb74512701B8143fCBbBbd5474a14B789773b8c93", insuranceProtocolFactory.address, "0x7fb31c05B41E10c3c4f05eEe7d3401fDb96b3f40");
    await collateralProtocol.deployed();
    console.log("CollateralProtocol deployed to:", collateralProtocol.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
