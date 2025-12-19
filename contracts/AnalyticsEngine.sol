// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import {FHE} from "@fhevm/solidity/lib/FHE.sol";
import {euint32} from "@fhevm/solidity/lib/FHE.sol";

// analytics on encrypted poll responses
contract AnalyticsEngine is ZamaEthereumConfig {
    using FHE for euint32;
    
    // poll => option => count (encrypted)
    mapping(uint256 => mapping(uint256 => euint32)) public optionCounts;
    
    function aggregateResponses(
        uint256 pollId,
        uint256 optionIndex,
        euint32 count
    ) external {
        optionCounts[pollId][optionIndex] = 
            optionCounts[pollId][optionIndex].add(count);
    }
    
    function getOptionCount(
        uint256 pollId,
        uint256 optionIndex
    ) external view returns (euint32) {
        return optionCounts[pollId][optionIndex];
    }
}

