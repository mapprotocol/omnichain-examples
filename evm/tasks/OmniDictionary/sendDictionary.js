const {address} = require("hardhat/internal/core/config/config-validation");

module.exports = async (taskArgs,hre) => {
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:",deployer.address);

    let dict = await ethers.getContractAt('OmniDictionary', taskArgs.address);
    let mos = await ethers.getContractAt('IMOSV3', "0xcDf0b81Fea68865158fa00Bd63627d6659A1Bf69");


    let amount = await mos.getMessageFee(taskArgs.chainid,"0x0000000000000000000000000000000000000000",500000)
    console.log( amount[0].toString());

        await (await dict.connect(deployer).sendDictionaryInput(
            taskArgs.chainid,
            taskArgs.target,
            taskArgs.key,
            taskArgs.value,
            {value:amount[0]}
        )).wait();


    console.log(`send ${taskArgs.key} :${taskArgs.value}  to chain ${taskArgs.chainid} success`);
}
