
module.exports = async (taskArgs,hre) => {
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:",deployer.address);

    console.log("mos salt:", taskArgs.salt);

    let factory = await ethers.getContractAt("IDeployFactory",taskArgs.factory)

    console.log("deploy factory address:",factory.address)

    let hash = await ethers.utils.keccak256(await ethers.utils.toUtf8Bytes(taskArgs.salt));

    let omniAddress = await factory.getAddress(hash);

    console.log("OMNI contract address:",omniAddress)

    let omni = await ethers.getContractAt('OmniDictionary', omniAddress);

    await (await omni.connect(deployer).setWhiteList(taskArgs.mos,"true")).wait();

    console.log(`OmniDictionary ${omniAddress} setWhiteList successfully `);

}