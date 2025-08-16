import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Dao", function () {

    async function deployDaoFixture() {
        const [owner, otherAccount] = await hre.ethers.getSigners();

        const Dao = await hre.ethers.getContractFactory("Dao");
        const dao = await Dao.deploy();

        return { dao, owner, otherAccount };
    }

    describe("CreateProposal", function () {
        it("Should create proposal", async function () {const { dao } = await loadFixture(deployDaoFixture);
            const description  = "Proposal to increase the budget for the project";
            const deadline = time.increaseTo(20);
            await dao.createProposal(description, deadline);
            const getProposal = await dao.getProposal(0);
            expect(getProposal.description).to.equal(description);

        });


    });
