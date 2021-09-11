import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const DubuChef = await hardhat.ethers.getContractFactory("DubuChef")
    const dubuChef = await DubuChef.deploy()
    console.log(`DubuChef address: ${dubuChef.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
