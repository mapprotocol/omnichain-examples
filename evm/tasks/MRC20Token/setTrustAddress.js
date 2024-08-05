const {getTronContract} = require("../utils/create");

function stringToHex(str) {
    return str
        .split("")
        .map(function (c) {
            return ("0" + c.charCodeAt(0).toString(16)).slice(-2);
        })
        .join("");
}

module.exports = async (taskArgs) => {
    const accounts = await ethers.getSigners();
    const deployer = accounts[0];

    console.log("deployer address:", deployer.address);

    let chains = taskArgs.chain.split(",");
    let addresses = taskArgs.address.split(",");

    if (hre.network.name === "Tron" || hre.network.name === "TronTest") {
        let morc20 = await getTronContract("MORC20Core", hre.artifacts, hre.network.name, taskArgs.token);
        console.log("token address:", morc20.address);

        await morc20.setTrustedAddress(chains, addresses).send();
    } else {
        let morc20 = await ethers.getContractAt("MORC20Core", taskArgs.token);
        console.log("token address:", morc20.address);

        await (await morc20.connect(deployer).setTrustedAddress(chains, addresses)).wait();
    }

    console.log(`${taskArgs.token} set trust address  ${taskArgs.address} to chain ${taskArgs.chain}  successful`);
};
