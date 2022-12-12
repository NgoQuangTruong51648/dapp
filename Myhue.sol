pragma solidity >=0.4.22 <0.7.0;

contract Ballot {
    // tạo kiểu dữ liệu mới là Voter
    struct Voter {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }
    struct Proposal {
        bytes32 name;
        uint256 voteCount;
    }
    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public prososals;

    //Khai báo giá trị ban đầu
    constructor(bytes32[] memory prososalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint256 i = 0; i < prososalNames.length; i++) {
            prososals.push(Proposal({name: prososalNames[i], voteCount: 0}));
        }
    }

    // Hàm cấp quyền Voting
    function giveRightToVote(address voter) public {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote"
        );
        require(!voters[voter].voted, "The voter already voted");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    // Hàm ủy quyền Voting
    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            prososals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    // Hàm voted
    function vote(uint256 prososal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = prososal;

        prososals[prososal].voteCount += sender.weight;
    }

    // Hàm tìm người có lượt vote cao nhất
    function winningProposal() public view returns (uint256 winningProposal_) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < prososals.length; p++) {
            if (prososals[p].voteCount > winningVoteCount) {
                winningVoteCount = prososals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Hàm in ra người chiến thắng
    function winnerName() public view returns (bytes32 winnerName_) {
        winnerName_ = prososals[winningProposal()].name;
    }

    // Corvert Byte32 to Strings
    function bytes32ToString(bytes32 winnerName_)
        public
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && winnerName_[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && winnerName_[i] != 0; i++) {
            bytesArray[i] = winnerName_[i];
        }
        return string(bytesArray);
    }

    // Covert String to Byte32
    function stringToBytes32(string memory source)
        public
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    
}
