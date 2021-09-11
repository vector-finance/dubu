import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const DubuPot = await hardhat.ethers.getContractFactory("DubuPot")
    const dubuPot = await DubuPot.deploy()
    console.log(`DubuPot address: ${dubuPot.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
