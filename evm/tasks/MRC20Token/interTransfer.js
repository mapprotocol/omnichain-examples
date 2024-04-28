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

    let morc20 = await ethers.getContractAt("IMORC20", taskArgs.token);
    console.log("morc20 address:", morc20.address);

    let tokenAddr = await morc20.connect(deployer).token();
    console.log("token address:", tokenAddr);

    let token = await ethers.getContractAt("IERC20Metadata", tokenAddr);
    let decimals = await token.decimals();
    console.log("token decimals:", decimals);

    let amount = ethers.utils.parseUnits(taskArgs.amount, decimals);
    console.log("token amount:", amount);

    let to = taskArgs.to;
    if (to === "") {
        to = deployer.address;
    }
    console.log("to address:", to);

    let fee = await morc20.connect(deployer).estimateFee(taskArgs.chain, taskArgs.gas);
    console.log("fee token:", fee[0]);
    console.log("fee amount:", fee[1]);

    await token.approve(morc20.address, amount);

    await morc20.connect(deployer)
        .interTransfer(deployer.address, taskArgs.chain, to, amount, taskArgs.gas, {
            value: fee[1],
            gasLimit: 500000
        });

    console.log(`${taskArgs.token} transfer out  ${taskArgs.amount} to chain ${taskArgs.chain}  successful`);
};
