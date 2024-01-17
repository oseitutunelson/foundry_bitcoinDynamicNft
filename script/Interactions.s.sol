//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {EtherNft} from '../src/etherNft.sol';
import {DevOpsTools} from 'lib/foundry-devops/src/DevOpsTools.sol';

contract MintEtherNft is Script{
    function run() external{
        address mostRecentlyDeployedNft = DevOpsTools.get_most_recent_deployment('EtherNft',block.chainid);
        mintNftOnContract(mostRecentlyDeployedNft);
    }

    function mintNftOnContract(address ethereum) public{
        vm.startBroadcast();
        EtherNft(ethereum).mintNft();
        vm.stopBroadcast();
    }
}