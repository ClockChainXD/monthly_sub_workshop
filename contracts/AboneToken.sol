// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AboneToken is ERC20 {
    constructor() ERC20("AboneToken", "ABONE") {
        _mint(msg.sender, 100 ether);
    }

    function mint(address to, uint amount) public {
        _mint(to, amount);
    }
}
