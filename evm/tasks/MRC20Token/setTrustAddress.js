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

    let token = await ethers.getContractAt("MORC20Core", taskArgs.token);

    console.log("token address:", token.address);

    let chains = taskArgs.chain.split(",");
    let addresses = taskArgs.address.split(",");

    await (await token.connect(deployer).setTrustedAddress(chains, addresses)).wait();

    console.log(`${taskArgs.token} set trust address  ${taskArgs.address} to chain ${taskArgs.chain}  successful`);
};
