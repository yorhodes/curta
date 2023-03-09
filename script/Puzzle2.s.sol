// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import { console, StdUtils } from "forge-std/Test.sol";

import { ISolve } from "../src/puzzles/Puzzle2.sol";
import { IPuzzle } from "../src/interfaces/IPuzzle.sol";

address constant yorke = 0x7714F5E0C26F10584180515FC704C06d4c17d4F0;

contract Solver is ISolve {
    function curtaPlayer() external pure override returns (address) {
        return yorke;
    }
}

contract Puzzle2 is Script {
    IPuzzle puzzle = IPuzzle(0x9f00c43700bc0000Ff91bE00841F8e04c0495000);

    function run() public {
        uint256 start = puzzle.generate(yorke);
        uint256 desiredPrefix = (0xF1A9 << 16) | start;
        console.logBytes32(bytes32(desiredPrefix));

        bytes32 salt = 0x77c4e155812c5e5e3db2fd216a26da1e1d45cb6e242569c7cf2b6f73013450ad;
        vm.prank(yorke);
        Solver solver = new Solver{salt: salt}();
        uint256 solution = uint256(uint160((address(solver))));

        console.logBytes32(bytes32(solution));

        vm.prank(yorke);
        bool solved = puzzle.verify(start, solution);
        console.log("solved", solved);
    }
}
