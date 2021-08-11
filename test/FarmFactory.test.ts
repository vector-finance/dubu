import { Contract } from "@ethersproject/contracts";
import { expect } from "chai";
import { ecsign } from "ethereumjs-util";
import { BigNumber, constants } from "ethers";
import { waffle } from "hardhat";
import DubuArtifact from "../artifacts/contracts/Dubu.sol/Dubu.json";
import FarmFactoryArtifact from "../artifacts/contracts/FarmFactory.sol/FarmFactory.json";
import TestCoinArtifact from "../artifacts/contracts/test/TestCoin.sol/TestCoin.json";
import { Dubu } from "../typechain";
import { FarmFactory } from "../typechain/FarmFactory";
import { TestCoin } from "../typechain/TestCoin";
import { mine } from "./shared/utils/blockchain";
import { getERC20ApprovalDigest } from "./shared/utils/standard";

const { deployContract } = waffle;

describe("FarmFactory", () => {

    let coin1: TestCoin;
    let coin2: TestCoin;
    let factory: FarmFactory;
    let reward: Dubu;

    const provider = waffle.provider;
    const [admin] = provider.getWallets();

    beforeEach(async () => {

        coin1 = await deployContract(
            admin,
            TestCoinArtifact,
            []
        ) as TestCoin;

        coin2 = await deployContract(
            admin,
            TestCoinArtifact,
            []
        ) as TestCoin;

        factory = await deployContract(
            admin,
            FarmFactoryArtifact,
            [100, (await provider.getBlockNumber()) + 100]
        ) as FarmFactory;

        reward = (new Contract(await factory.dubu(), DubuArtifact.abi, provider) as Dubu).connect(admin);
    })

    context("new FarmFactory", async () => {
        it("add/deposit", async () => {

            await expect(factory.add(coin1.address, 100))
                .to.emit(factory, "Add")
                .withArgs(coin1.address, 100)

            await coin1.approve(factory.address, 100);

            await expect(factory.deposit(0, 100))
                .to.emit(factory, "Deposit")
                .withArgs(admin.address, 0, 100)

            await mine(83)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(110) // +10%

            await mine(3)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(550) // +10%
        });

        it("deposit with permit", async () => {

            await factory.add(coin1.address, 100);

            const nonce = await coin1.nonces(admin.address)
            const deadline = constants.MaxUint256
            const digest = await getERC20ApprovalDigest(
                coin1,
                { owner: admin.address, spender: factory.address, value: BigNumber.from(100) },
                nonce,
                deadline
            )

            const { v, r, s } = ecsign(Buffer.from(digest.slice(2), "hex"), Buffer.from(admin.privateKey.slice(2), "hex"))

            await expect(factory.depositWithPermit(0, 100, deadline, v, r, s))
                .to.emit(factory, "Deposit")
                .withArgs(admin.address, 0, 100)

            await mine(84)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(110) // +10%

            await mine(3)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(550) // +10%
        });

        it("deposit with permit max", async () => {

            await factory.add(coin1.address, 100);

            const nonce = await coin1.nonces(admin.address)
            const deadline = constants.MaxUint256
            const digest = await getERC20ApprovalDigest(
                coin1,
                { owner: admin.address, spender: factory.address, value: constants.MaxUint256 },
                nonce,
                deadline
            )

            const { v, r, s } = ecsign(Buffer.from(digest.slice(2), "hex"), Buffer.from(admin.privateKey.slice(2), "hex"))

            await expect(factory.depositWithPermitMax(0, 100, deadline, v, r, s))
                .to.emit(factory, "Deposit")
                .withArgs(admin.address, 0, 100)

            await mine(84)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(110) // +10%

            await mine(3)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(550) // +10%
        });

        it("withdraw", async () => {

            await factory.add(coin1.address, 100);
            await coin1.approve(factory.address, 100);
            await factory.deposit(0, 100);

            await mine(83)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(110) // +10%

            await expect(factory.withdraw(0, 100))
                .to.emit(factory, "Withdraw")
                .withArgs(admin.address, 0, 100)

            await mine(2)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(220) // +10%
        });

        it("add twice", async () => {

            await factory.add(coin1.address, 100);
            await factory.add(coin2.address, 100);
            await coin1.approve(factory.address, 100);
            await factory.deposit(0, 100);

            await mine(82)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(55) // +10%

            await mine(3)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(275) // +10%
        });

        it("set", async () => {

            await factory.add(coin1.address, 100);
            await factory.add(coin2.address, 100);
            await coin1.approve(factory.address, 100);
            await factory.deposit(0, 100);

            await mine(82)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(5)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(4)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(0)

            await mine(1)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(55) // +10%

            await expect(factory.set(1, 200))
                .to.emit(factory, "Set")
                .withArgs(1, 200)

            await mine(2)
            await factory.deposit(0, 0);
            expect(await reward.balanceOf(admin.address)).to.equal(220) // +10%
        });
    })
})