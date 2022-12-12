pragma solidity >=0.4.22 <0.7.0;
contract Ballot {
struct Voter {
    uint weight;
    bool voted;
    address delegate;
    uint vote;
    }
    struct Proposal {
     bytes32 name;
     uint voteCount;
    }
    address public chairperson;

    mapping (address => Voter) public voters;
    
    Proposal[] public prososals;
    
    constructor(bytes32[] memory prososalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < prososalNames.length; i++) {
            prososals.push (Proposal({
                name: prososalNames [i] ,
                voteCount: 0 
            }));
        }
    }
    
        function giveRightToVote(address voter) public {
        require (
            msg.sender == chairperson,
            "Only chairperson can give right to vote"
        );
        require (
            !voters[voter].voted,
            "The voter already voted"
        );
        require (voters[voter].weight == 0);
        voters[voter].weight = 1;
    }
    
        function delegate (address to) public {
            Voter storage sender = voters[msg.sender];
            require(!sender.voted, "You already voted." );
            require(to != msg.sender, "Self-delegation is disallowed.");
            
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;
                require(to != msg.sender, "Found loop in delegation.");
            }
            sender.voted = true;
            sender.delegate = to;
            Voter storage delegate_ = voters[to];
            if (delegate_.voted) {
                prososals [delegate_.vote].voteCount += sender.weight;
            } else {
                delegate_.weight += sender.weight;
            }
        }
        
        function vote(uint prososal) public {
            Voter storage sender = voters[msg.sender];
            require(sender.weight != 0, "Has no right to vote");
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = prososal;
            
            prososals[prososal].voteCount += sender.weight;
        }
        
        function winningProposal () public view
                returns (uint winningProposal_)
        {
            uint winningVoteCount = 0;
            for (uint p = 0; p < prososals.length; p++) {
                if (prososals [p].voteCount > winningVoteCount) {
                    winningVoteCount = prososals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }
        
        function winnerName() public view
                returns (bytes32 winnerName_)
        {
            winnerName_ = prososals[winningProposal()].name;
        }        
       
   
}