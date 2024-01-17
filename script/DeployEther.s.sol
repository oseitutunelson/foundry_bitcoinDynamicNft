//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {EtherNft} from '../src/etherNft.sol';
import {Base64} from '@openzeppelin/contracts/utils/Base64.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployEther is Script{

    function run() external returns (EtherNft,HelperConfig) {
       string memory priceBefore = vm.readFile('./img/priceBefore.svg');
       string memory priceAfter = vm.readFile('./img/priceAfter.svg');
       HelperConfig helperConfig = new HelperConfig();
       address priceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        EtherNft ethereum = new EtherNft(svgToImageURI(priceBefore),svgToImageURI(priceAfter),priceFeed);
        vm.stopBroadcast();
        return (ethereum,helperConfig);
    }
    
    //convert svg to encoded format
      function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURI = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg))) // Removing unnecessary type castings, this line can be resumed as follows : 'abi.encodePacked(svg)'
        );
        return string(abi.encodePacked(baseURI, svgBase64Encoded));
    }
}