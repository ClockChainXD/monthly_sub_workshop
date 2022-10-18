// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "./AbonmanSozlesmesi.sol";
import "./CloneFactory.sol";

interface KeeperRegistrarInterface {
    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint96 amount,
        uint8 source,
        address sender
    ) external;
}

contract Makalelik is Ownable {
    LinkTokenInterface public immutable i_link;
    address public immutable registrar;
    AutomationRegistryInterface public immutable i_registry;
    bytes4 registerSig = KeeperRegistrarInterface.register.selector;

    struct abone {
        uint256 baslangicTarihi;
        uint256 bitisTarihi;
        address abonmanSozlesmesi;
        uint256 upkeepId;
    }
    mapping(address => abone) public abonelikler;
    address odemeToken;
    uint256 abonelikUcreti = 1 ether;

    constructor(
        LinkTokenInterface _link,
        address _registrar,
        AutomationRegistryInterface _registry,
        address _odemeToken
    ) {
        i_link = _link;
        registrar = _registrar;
        i_registry = _registry;
        odemeToken = _odemeToken;
    }

    function get_abonelikler(address adres) public view returns (abone memory) {
        return abonelikler[adres];
    }

    function abone_ol(
        string memory name,
        uint32 gasLimit,
        uint96 amount,
        address anaSozlesme
    ) public {
        require(
            abonelikler[msg.sender].baslangicTarihi == 0,
            "Abonelik mevcut"
        );
        require(
            IERC20(odemeToken).balanceOf(msg.sender) >= abonelikUcreti,
            "Yetersiz bakiye"
        );
        AbonmanSozlesmesi abonmanSozlesmesi = AbonmanSozlesmesi(createClone(anaSozlesme));
        abonmanSozlesmesi.initialize(
            msg.sender,
            block.timestamp,
            block.timestamp,
            abonelikUcreti,
            odemeToken,
            owner()
        );
        (State memory state, Config memory _c, address[] memory _k) = i_registry.getState();
        uint256 oldNonce = state.nonce;
        bytes memory payload = abi.encode(
                              name,
                              "0x",
                              address(abonmanSozlesmesi),
                              gasLimit,
                              owner(),
                              "0x",
                              amount,
                              0,
                              address(this)
                            );
        i_link.transferAndCall(registrar, amount, bytes.concat(registerSig, payload));
        (state, _c, _k) = i_registry.getState();
        uint256 newNonce = state.nonce;
        if (newNonce == oldNonce + 1) {
          uint256 upkeepID = uint256(
              keccak256(
                abi.encodePacked(blockhash(block.number - 1), address(i_registry), uint32(oldNonce))
                ));
          abone memory new_abone = abone(block.timestamp ,block.timestamp, address(abonmanSozlesmesi), upkeepID);
          abonelikler[msg.sender] = new_abone;
        } else {
          revert("auto-approve disabled");
        }
    }
}
