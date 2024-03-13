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

    let to = taskArgs.to;
    if (to === "") {
        to = deployer.address;
    }

    console.log("to address:", to);

    let fee = await token.connect(deployer).estimateFee(taskArgs.chain, taskArgs.gas);
    console.log("fee token:", fee[0]);
    console.log("fee amount:", fee[1]);

    await (
        await token.connect(deployer).interTransfer(
                deployer.address,
                taskArgs.chain,
                to,
                taskArgs.amount,
                taskArgs.gas, {
                value: fee[1],
            })
    ).wait();

    console.log(`${taskArgs.token} transfer out  ${taskArgs.amount} to chain ${taskArgs.chain}  successful`);
};
