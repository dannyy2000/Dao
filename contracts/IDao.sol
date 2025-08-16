// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


interface IDao{
    struct Proposal {
        uint256 id;
        string description;
        uint256 deadline;
        uint256 yesVotes;
        uint256 noVotes;
        Status status;
    }

    struct User{
        address userAddress;

    }


    enum Status{
    PENDING,
    PASSED,
    FAILED,
    CLOSED
}

    function createProposal(string calldata _description, uint256 deadline) external;
    function vote(uint256 proposalId,bool support) external;
    function getProposal(uint256 proposalId) external view returns (Proposal memory);
    function approveProposal(uint256 proposalId) external;
    function rejectProposal(uint256 proposalId) external;
}