// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AbonmanSozlesmesi is AutomationCompatibleInterface {
    address abonman;
    address odeme_yontemi;
    address kasa;
    uint sozlesme_baslangici;
    uint sozlesme_bitisi;
    uint aylik_ucret;
    
    IERC20 busd = IERC20(odeme_yontemi);
    constructor(){}
    
    function initialize(
        address kullanici, uint _sozlesme_baslangici, uint _sozlesme_bitisi, uint _aylik_ucret, address _odeme_yontemi, address _kasa) external {
        abonman = kullanici;
        sozlesme_baslangici = _sozlesme_baslangici;
        sozlesme_bitisi = _sozlesme_bitisi;
        odeme_yontemi = _odeme_yontemi;
        kasa = _kasa;
        aylik_ucret = _aylik_ucret;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = block.timestamp >= sozlesme_bitisi;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if (block.timestamp >= sozlesme_bitisi) {
            busd.transferFrom(abonman, kasa, aylik_ucret);
            sozlesme_bitisi = block.timestamp + 30 days;
        }
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }

    function get_address() external view returns(address){
        return address(this);
    }
}