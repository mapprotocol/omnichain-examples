
module.exports = async (taskArgs,hre) => {
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:",deployer.address);

    let dict = await ethers.getContractAt('OmniDictionary', taskArgs.echoAddress);

    let value = await dict.connect(deployer).dictionary(taskArgs.key);

    console.log(`${taskArgs.key} : ${value}`);

}