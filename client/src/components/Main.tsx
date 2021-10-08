import {useEthers} from "@usedapp/core";
import helperConfig from "../helper-config.json"
import networkMapping from "../chain-info/deployments/map.json"
import dai from "../dai.png"
import { YourWallet } from "./yourWallet/YourWallet";

export const Main = () => {

    const {chainId, error} =useEthers()
    const networkName = chainId ? helperConfig[chainId] : "dev"
    
    const dappTokenAddress = chainId ? networkMapping[stringChainId]["DappToken"][0] : constants.AddressZero
    const wethTokenAddress = chainId ? brownieConfig["networks"][networkName]["weth_token"] : constants.AddressZero // brownie config
    const fauTokenAddress = chainId ? brownieConfig["networks"][networkName]["fau_token"] : constants.AddressZero

    const supportedTokens:Array<Token> = [
        {
            image: dapp,
            address: dappTokenAddress,
            name: "DAPP"
        },
        {
            image:eth,
            address: wethTokenAddress,
            name: "WETH"
        },
        {
            image:fau,
            address: fauTokenAddress,
            name: "DAI"
        }

    ]
    
    return (
        <div>

            <YourWallet supportedTokens/>
        </div>
    )

}