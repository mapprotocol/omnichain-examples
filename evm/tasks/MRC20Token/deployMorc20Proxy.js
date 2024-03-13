module.exports = async (taskArgs, hre) => {
    const { deploy } = hre.deployments;
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    if (taskArgs.salt === "") {
        await deploy("MORC20CommonProxy", {
            from: deployer.address,
            args: [taskArgs.token, taskArgs.mos, deployer.address],
            log: true,
            contract: "MORC20CommonProxy",
        });

        let morc20Proxy = await ethers.getContract("MORC20CommonProxy");

        console.log("MORC20 Proxy address:", morc20Proxy.address);
    } else {
        let proxyContract = await ethers.getContractFactory("MORC20CommonProxy");

        let initData = await ethers.utils.defaultAbiCoder.encode(
            ["address", "address", "address"],
            [taskArgs.token, taskArgs.mos, deployer.address]
        );

        let deployData = proxyContract.bytecode + initData.substring(2);

        console.log("MORC20CommonToken salt:", taskArgs.salt);

        let hash = await ethers.utils.keccak256(await ethers.utils.toUtf8Bytes(taskArgs.salt));

        let factory = await ethers.getContractAt("IDeployFactory", taskArgs.factory);

        console.log("deploy factory address:", factory.address);

        await (await factory.connect(deployer).deploy(hash, deployData, 0)).wait();

        let proxyAddress = await factory.connect(deployer).getAddress(hash);

        console.log("MORC20 Proxy:", proxy);

        let proxy = await ethers.getContractAt("MORC20CommonProxy", proxyAddress);

        let admin = await proxy.connect(deployer).owner();

        console.log(
            `MORC20CommonProxy contract address is ${proxyAddress} init admin address is ${admin} deploy contract salt is ${hash}`
        );
    }
};
