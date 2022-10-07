 // SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract Fibonacci {
    function fib(uint n) pure external returns(uint) {
        if(n == 0) {
            return 0;
        }
        uint fi_1 = 1;
        uint fi_2 = 1;
        for(uint i = 0; i < n - 2; i++) {
            uint fi = fi_1 + fi_2;
            fi_2 = fi_1;
            fi_1 = fi;
        }
        return fi_1;
    }
}