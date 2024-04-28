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

    let token = await ethers.getContractAt("MORC20Token", taskArgs.token);

    console.log("token address:", token.address);

    await (await token.connect(deployer).transferOwnership(taskArgs.owner)).wait();

    console.log(`${taskArgs.token} transfer owner to chain ${taskArgs.owner}  successful`);
};
