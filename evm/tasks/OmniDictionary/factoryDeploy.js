//const {ethers} = require("hardhat");
module.exports = async (taskArgs, hre) => {
    const { deploy } = hre.deployments;
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    let Omni = await ethers.getContractFactory("OmniDictionary");

    let initData = await ethers.utils.defaultAbiCoder.encode(["address"], [deployer.address]);

    let deployData = Omni.bytecode + initData.substring(2);

    console.log("Omni salt:", taskArgs.salt);

    let hash = await ethers.utils.keccak256(await ethers.utils.toUtf8Bytes(taskArgs.salt));

    let factory = await ethers.getContractAt("IDeployFactory", taskArgs.factory);

    console.log("deploy factory address:", factory.address);

    await (await factory.connect(deployer).deploy(hash, deployData, 0)).wait();

    let OmniAddress = await factory.connect(deployer).getAddress(hash);

    console.log("OmniAddress:", OmniAddress);

    let omni = await ethers.getContractAt("OmniDictionary", OmniAddress);

    let admin = await omni.connect(deployer).owner();

    console.log(admin);
    await (await omni.connect(deployer).setMapoService(taskArgs.mos)).wait();

    console.log("OmniDictionary set MOS successful");

    await (await omni.connect(deployer).setWhiteList(taskArgs.mos, true)).wait();

    console.log("OmniDictionary set whitelist successful");

    console.log(
        `OmniDictionary contract address is ${OmniAddress} init admin address is ${admin} deploy contract salt is ${hash}`
    );
};
