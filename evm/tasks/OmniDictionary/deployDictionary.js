
module.exports = async (taskArgs,hre) => {
    const {deploy} = hre.deployments
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:",deployer.address);

    await deploy('OmniDictionary', {
        from: deployer.address,
        args: [],
        log: true,
        contract: 'OmniDictionary'
    })

    let dict = await ethers.getContract('OmniDictionary');

    console.log("OmniDictionary address:", dict.address);

    console.log("MOS address:", taskArgs.mos);

    await (await dict.connect(deployer).setMapoService(taskArgs.mos)).wait()

    console.log("OmniDictionary set MOS successful");

    await (await dict.connect(deployer).setWhiteList(taskArgs.mos, true)).wait()

    console.log("OmniDictionary set whitelist successful");

}