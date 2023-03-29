
module.exports = async (taskArgs,hre) => {
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:",deployer.address);

    let dict = await ethers.getContractAt('OmniDictionary', taskArgs.address);

        await (await dict.connect(deployer).sendDictionaryInput(
            taskArgs.chainid,
            taskArgs.target,
            taskArgs.key,
            taskArgs.value,
            {gasLimit:2000000,value:1500000000000000}
        )).wait();


    console.log(`send ${taskArgs.key} :${taskArgs.value}  to chain ${taskArgs.chainid} success`);
}