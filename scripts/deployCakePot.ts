import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const CakePot = await hardhat.ethers.getContractFactory("CakePot")
    const cakePot = await CakePot.deploy()
    console.log(`CakePot address: ${cakePot.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
