module.exports = async (taskArgs, hre) => {
    const {deploy} = hre.deployments
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    if (taskArgs.salt === ""){
        await deploy('MORC20CommonToken', {
            from: deployer.address,
            args: [taskArgs.name,taskArgs.symbol,taskArgs.mos,deployer.address],
            log: true,
            contract: 'MORC20CommonToken',
        })

        let morc20Token = await ethers.getContract('MORC20CommonToken');

        console.log("MORC20CommonToken address:", morc20Token.address);
    }else{
        let Morc20 = await ethers.getContractFactory('MORC20CommonToken');

        let initData = await ethers.utils.defaultAbiCoder.encode(
            ["stirng","string","address","address"],
            [taskArgs.name,taskArgs.symbol,taskArgs.mos,deployer.address]
        )

        let deployData = Morc20.bytecode + initData.substring(2);

        console.log("MORC20CommonToken salt:", taskArgs.salt);

        let hash = await ethers.utils.keccak256(await ethers.utils.toUtf8Bytes(taskArgs.salt));

        let factory = await ethers.getContractAt("IDeployFactory",taskArgs.factory)

        console.log("deploy factory address:",factory.address)

        await (await factory.connect(deployer).deploy(hash,deployData,0)).wait();

        let Morc20Token = await factory.connect(deployer).getAddress(hash)

        console.log("MORC20CommonToken:",Morc20Token);

        let morc20 = await ethers.getContractAt('MORC20CommonToken',Morc20Token);

        let admin = await morc20.connect(deployer).owner();

        console.log(`MORC20CommonToken contract address is ${Morc20Token} init admin address is ${admin} deploy contract salt is ${hash}`)
    }


}