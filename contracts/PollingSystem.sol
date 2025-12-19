// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {FHE} from "@fhevm/solidity/lib/FHE.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// polling system with encrypted responses
contract PollingSystem is ZamaEthereumConfig {
    using FHE for euint32;
    
    struct Poll {
        address creator;
        string question;
        string[] options;
        uint256 endTime;
        bool active;
    }
    
    struct Response {
        address respondent;
        euint32 answer;      // encrypted answer
        uint256 timestamp;
    }
    
    mapping(uint256 => Poll) public polls;
    mapping(uint256 => Response[]) public responses;
    mapping(uint256 => mapping(address => bool)) public hasResponded;
    uint256 public pollCounter;
    
    event PollCreated(uint256 indexed pollId, address creator);
    event ResponseReceived(uint256 indexed pollId, address respondent);
    
    function createPoll(
        string memory question,
        string[] memory options,
        uint256 duration
    ) external returns (uint256 pollId) {
        pollId = pollCounter++;
        polls[pollId] = Poll({
            creator: msg.sender,
            question: question,
            options: options,
            endTime: block.timestamp + duration,
            active: true
        });
        emit PollCreated(pollId, msg.sender);
    }
    
    function submitResponse(
        uint256 pollId,
        euint32 encryptedAnswer
    ) external {
        Poll storage poll = polls[pollId];
        require(poll.active, "Poll not active");
        require(block.timestamp < poll.endTime, "Poll ended");
        require(!hasResponded[pollId][msg.sender], "Already responded");
        
        responses[pollId].push(Response({
            respondent: msg.sender,
            answer: encryptedAnswer,
            timestamp: block.timestamp
        }));
        
        hasResponded[pollId][msg.sender] = true;
        emit ResponseReceived(pollId, msg.sender);
    }
    
    function getResponseCount(uint256 pollId) external view returns (uint256) {
        return responses[pollId].length;
    }
}

