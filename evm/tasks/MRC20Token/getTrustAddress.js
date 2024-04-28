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

    let morc20 = await ethers.getContractAt("MORC20Core", taskArgs.token);

    console.log("morc20 address:", morc20.address);

    let mosAddr = await morc20.mos();
    console.log("mos address: ", mosAddr);

    let targetAddr = await morc20.getTrustedAddress(taskArgs.chain);
    console.log("trusted address", targetAddr);

    let fee = await morc20.connect(deployer).estimateFee(taskArgs.chain, taskArgs.gas);
    console.log("fee token:", fee[0]);
    console.log("fee amount:", fee[1]);
};
