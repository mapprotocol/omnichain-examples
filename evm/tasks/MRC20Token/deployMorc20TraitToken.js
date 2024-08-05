let { create, getTronContract, toHex} = require("../utils/create.js");

module.exports = async (taskArgs, hre) => {
    const { deploy } = hre.deployments;
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    console.log("deploy token type:", taskArgs.token);

    let mos = taskArgs.mos;
    if (hre.network.name === "Tron" || hre.network.name === "TronTest") {
        mos = await toHex(taskArgs.mos, hre.network.name);
    }

    let proxy_salt = taskArgs.salt;
    let tokenAddr = await create(hre, deployer, taskArgs.token,
        ["string", "string", "address", "uint256", "address"],
        [taskArgs.name, taskArgs.symbol, mos, taskArgs.totalsupply, deployer.address],
        proxy_salt);

    let admin;
    if (hre.network.name === "Tron" || hre.network.name === "TronTest") {
        // bridge_addr = await fromHex(bridge_addr, networkName);
        let morc20 = await getTronContract(taskArgs.token, hre.artifacts, hre.network.name, tokenAddr);
        admin = await morc20.owner().call();
    } else {
        let morc20 = await ethers.getContractAt(taskArgs.token, tokenAddr);
        admin = await morc20.connect(deployer).owner();
    }

    console.log(`deployed token [${taskArgs.token}] at [${tokenAddr}] with admin [${admin}]`);
};
