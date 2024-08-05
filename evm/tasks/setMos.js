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

    let executor = await ethers.getContractAt("MapoExecutor", taskArgs.token);

    console.log("token address:", executor.address);

    await (await executor.connect(deployer).setMosAddress(taskArgs.address)).wait();

    console.log(`set mos address  ${await executor.mos()} successful`);
};
