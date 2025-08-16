import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Dao", function () {

    async function deployDaoFixture() {
        const [owner, otherAccount,secondAccount] = await hre.ethers.getSigners();

        const Dao = await hre.ethers.getContractFactory("Dao");
        const dao = await Dao.deploy();

        return {dao, owner, otherAccount,secondAccount};
    }

    describe("CreateProposal", function () {
        it("Should create proposal", async function () {
            const {dao} = await loadFixture(deployDaoFixture);
            const description = "Proposal to increase the budget for the project";
            const deadline = 60 * 60 * 24;
            await dao.createProposal(description, deadline);
            const getProposal = await dao.getProposal(0);
            expect(getProposal.description).to.equal(description);

        });


    })


    describe("Vote", function () {
        it("Should vote on proposal", async function () {
            const {dao} = await loadFixture(deployDaoFixture);
            const description = "Proposal to increase the budget for the project";
            const deadline = 60 * 60 * 24;
            await dao.createProposal(description, deadline);
            await dao.vote(0, true);
            const getProposal = await dao.getProposal(0);
            expect(getProposal.votesFor).to.equal(1);
        });

        it("Should not allow voting after deadline", async function () {
            const {dao} = await loadFixture(deployDaoFixture);
            const description = "Proposal to increase the budget for the project";
            const deadline = 1;
            await dao.createProposal(description, deadline);
            await time.increase(2);
            await expect(dao.vote(0, true)).to.be.revertedWith("Voting deadline has passed");
        });

        it("Should not allow voting if voting is not pending",async function(){
            const {dao,owner,otherAccount,secondAccount} = await loadFixture(deployDaoFixture);
            const description = "Proposal to increase the budget for the project";
            const deadline = 60 * 60 * 24;
            await dao.createProposal(description, deadline);
            await dao.connect(otherAccount).vote(0, true);
            await dao.connect(secondAccount).vote(0, true);
            await dao.connect(owner).vote(0, true);
            await time.increase(2);

            await expect(dao.vote(0, true)).to.be.revertedWith("Voting is closed for this proposal");
        })
    });
});
