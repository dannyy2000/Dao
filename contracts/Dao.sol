// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./IDao.sol";

contract Dao is IDao{

    mapping(address => bool) isAdmin;
    Proposal[] public failedProposals;
    Proposal[] public passedProposals;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => User) public users;

    uint256  proposalCount;
    uint256 uuid;
    address public admin;
    mapping(uint256 => mapping(address => bool))  hasVoted;
    uint256  totalVotes;
    uint256 approvalCount;
    uint256 rejectionCount;


    modifier onlyAdmin() {
        require(msg.sender == admin || isAdmin[msg.sender] == true, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
        isAdmin[admin] = true;
    }



    function createProposal(string calldata _description, uint256 deadline) external  {

        Proposal memory newProposal;
            newProposal.id = uuid;
            newProposal.description = _description;
            newProposal.yesVotes = 0;
            newProposal.noVotes = 0;
            newProposal.deadline = block.timestamp + deadline;
            newProposal.status = Status.PENDING;


        proposals[uuid] = newProposal;
        uuid++;

    }

    function vote(uint256 proposalId, bool support) external onlyAdmin{
        require(proposalId < uuid, "Proposal does not exist");
        require(!hasVoted[proposalId][msg.sender], "You have already voted on this proposal");
        require(proposals[proposalId].status == Status.PENDING, "Voting is closed for this proposal");
        require(block.timestamp < proposals[proposalId].deadline, "Voting deadline has passed");

        Proposal storage proposal = proposals[proposalId];
        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }


        totalVotes++;
        if(totalVotes == 3){
            proposal.status = Status.CLOSED;
        }

    }

    function approveProposal(uint256 proposalId) external onlyAdmin{
        require(proposalId < uuid, "Proposal does not exist");
        require(proposals[proposalId].status == Status.CLOSED, "Proposal is not CLOSED");
        require(approvalCount <= 2, "Approval count must be 2 to pass the proposal");

        Proposal storage proposal = proposals[proposalId];
        passedProposals.push(proposal);
        approvalCount++;
        if( proposal.yesVotes > proposal.noVotes && approvalCount == 2) {
            proposal.status = Status.PASSED;
        } else {
            proposal.status = Status.CLOSED;
        }
    }

    function rejectProposal(uint256 proposalId) external onlyAdmin{
        require(proposalId < uuid, "Proposal does not exist");
        require(proposals[proposalId].status == Status.PENDING, "Proposal is not pending");
        require(rejectionCount <= 2, "Rejection count must be 2 to fail the proposal");

        Proposal storage proposal = proposals[proposalId];

        failedProposals.push(proposal);
        rejectionCount++;
        if (proposal.noVotes > proposal.yesVotes && rejectionCount == 2) {
            proposal.status = Status.FAILED;
        } else {
            proposal.status = Status.CLOSED;
        }
    }


    function getProposal(uint256 proposalId) external view returns (Proposal memory){
        return proposals[proposalId];
    }

    function addAdmin(address admin) external onlyAdmin {
        isAdmin[admin] = true;
    }








}