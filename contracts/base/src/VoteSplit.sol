// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VoteSplit {
    struct Proposal {
        string description;
        uint256 totalFunds;
        uint256 votingDeadline;
        bool executed;
    }

    struct Vote {
        uint256 voiceCredits;
        mapping(uint256 => uint256) votes;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Vote)) public votes;
    mapping(uint256 => mapping(uint256 => uint256)) public optionVotes;
    uint256 public proposalCount;

    event ProposalCreated(uint256 indexed proposalId, string description);
    event Voted(uint256 indexed proposalId, address indexed voter, uint256 option, uint256 credits);

    error VotingEnded();
    error InsufficientCredits();

    function createProposal(string memory description, uint256 duration) external payable returns (uint256) {
        uint256 proposalId = proposalCount++;
        proposals[proposalId] = Proposal({
            description: description,
            totalFunds: msg.value,
            votingDeadline: block.timestamp + duration,
            executed: false
        });
        emit ProposalCreated(proposalId, description);
        return proposalId;
    }

    function vote(uint256 proposalId, uint256 option, uint256 voiceCredits) external {
        if (block.timestamp > proposals[proposalId].votingDeadline) revert VotingEnded();
        uint256 cost = voiceCredits * voiceCredits;
        votes[proposalId][msg.sender].votes[option] += voiceCredits;
        optionVotes[proposalId][option] += voiceCredits;
        emit Voted(proposalId, msg.sender, option, voiceCredits);
    }

    function getOptionVotes(uint256 proposalId, uint256 option) external view returns (uint256) {
        return optionVotes[proposalId][option];
    }
}
