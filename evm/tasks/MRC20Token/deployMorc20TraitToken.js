module.exports = async (taskArgs, hre) => {
    const {deploy} = hre.deployments
    const accounts = await ethers.getSigners()
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    if (taskArgs.salt === ""){
        await deploy(taskArgs.token, {
            from: deployer.address,
            args: [taskArgs.name,taskArgs.symbol,taskArgs.mos,taskArgs.totalsupply,deployer.address],
            log: true,
            contract: taskArgs.token,
        })

        let morc20Token = await ethers.getContract(taskArgs.token);

        console.log(`${taskArgs.token} deploy address : ${morc20Token.address}`);
    }else{
        let Morc20 = await ethers.getContractFactory(taskArgs.token);

        let initData = await ethers.utils.defaultAbiCoder.encode(
            ["string","string","address","uint256","address"],
            [taskArgs.name,taskArgs.symbol,taskArgs.mos,taskArgs.totalsupply,deployer.address]
        )

        let deployData = Morc20.bytecode + initData.substring(2);

        let hash = await ethers.utils.keccak256(await ethers.utils.toUtf8Bytes(taskArgs.salt));

        let factory = await ethers.getContractAt("IDeployFactory",taskArgs.factory)

        console.log("deploy factory address:",factory.address)

        await (await factory.connect(deployer).deploy(hash,deployData,0)).wait();

        let Morc20Token = await factory.connect(deployer).getAddress(hash)

        console.log(`${taskArgs.token} address : ${Morc20Token}`);

        let morc20 = await ethers.getContractAt(taskArgs.token,Morc20Token);

        let admin = await morc20.connect(deployer).owner();

        console.log(`${taskArgs.token} contract address is ${Morc20Token} init admin address is ${admin} deploy contract salt is ${hash}`)
    }


}