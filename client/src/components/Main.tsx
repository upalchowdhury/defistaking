import {useEthers} from "@usedapp/core";
import helperConfig from "../helper-config.json"
import networkMapping from "../chain-info/deployments/map.json"


export const Main = () => {

    const {chainId, error} =useEthers()
    const networkName = chainId ? helperConfig[chainId] : "dev"
    
    const dappTokenAddress = 

    
    return (
        <div></div>
    )

}