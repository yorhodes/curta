// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { Script } from "forge-std/Script.sol";
import { console, StdUtils } from "forge-std/Test.sol";

import "../src/Curta.sol";
import "../src/puzzles/Puzzle17.sol";

contract Puzzle17 is Script {
    using {into} for IKey;

    string constant killer = "Pythagoras";
    string constant victim = "Hippasus";

    MurderMystery puzzle = MurderMystery(0xc7faA31d69f2A38BD7E0A899D853Beca05D529CF);
    Curta curta = Curta(0x0000000006bC8D9e5e9d436217B88De704a9F307);

    // PRECOMPILES!

    // sha256 := sha256 hash of the input
    IKey sand = IKey(0x0000000000000000000000000000000000000002);
    uint256 witness1 = 8;
    // 2 ** 8 = 256
    // sha256(prefix + p_sand) = 0x00000000

    Password p_sand = Password.wrap(bytes32(0x951e8109000000a8000000000000000000000000000000000000000000000000));

    // identity := returns the input
    IKey wave = IKey(0x0000000000000000000000000000000000000004);
    uint256 witness2 = 4;
    // 4 ** 4 = 256

    Password p_wave = Password.wrap(bytes32(0x0));

    // RIPEMD-160 := RIPEMD-160 hash of the input
    IKey shadow = IKey(0x0000000000000000000000000000000000000003);
    uint256 witness3 = 8;
    // 8 ** 3 = 512

    Password p_shadow = Password.wrap(bytes32(0x0));
    // ripemd160(prefix + p_shadow)[0:4] = 0x00000000
    // The result 20-byte hash right aligned to 32 bytes

    address constant player = 0x7714F5E0C26F10584180515FC704C06d4c17d4F0;
    uint32 constant puzzleId = 17;

    // forge inspect Curta storage --pretty
    bytes32 constant solveMappingSlot = bytes32(uint256(11));
    bytes32 constant playerMappingSlot = keccak256(abi.encode(player, solveMappingSlot));
    bytes32 constant puzzleMappingSlot = keccak256(abi.encode(puzzleId, playerMappingSlot));

    function run() public {
        vm.label(address(puzzle), "MurderMystery");
        vm.label(address(curta), "Curta");

        uint256 solution = puzzle.solution();

        bool solved = curta.hasSolvedPuzzle(player, puzzleId);

        if (solved) {
            // pretend the player has not solved the puzzle
            vm.store(address(curta), puzzleMappingSlot, bytes32(uint256(0)));
            solved = curta.hasSolvedPuzzle(player, puzzleId);
        }

        assert(!solved);

        vm.startPrank(player);

        puzzle.solve(
            sand,
            p_sand,
            wave,
            p_wave,
            shadow,
            p_shadow,
            witness1,
            witness2,
            witness3,
            killer,
            victim
        );

        curta.solve(puzzleId, solution);

        vm.stopPrank();
    }
}
