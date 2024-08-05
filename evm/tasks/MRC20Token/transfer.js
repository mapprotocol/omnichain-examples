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



    let to = taskArgs.to;
    if (to === "") {
        to = deployer.address;
    }
    console.log("to address:", to);

    if (hre.network.name === "Tron" || hre.network.name === "TronTest") {
        let token = await getTronContract("IERC20Metadata", hre.artifacts, hre.network.name, taskArgs.token);
        console.log("token address:", token.address);

        let decimals = await token.decimals().call();
        console.log("token decimals:", decimals);

        let amount = ethers.utils.parseUnits(taskArgs.amount, decimals);
        console.log("token amount:", amount);

        await token.transfer(to, amount).send();

    } else {
        let token = await ethers.getContractAt("IERC20Metadata", taskArgs.token);
        console.log("token address:", token.address);

        let decimals = await token.decimals();
        console.log("token decimals:", decimals);

        let amount = ethers.utils.parseUnits(taskArgs.amount, decimals);
        console.log("token amount:", amount);

        await token.connect(deployer).transfer(to, amount);
    }



    console.log(`${taskArgs.token} transfer out  ${taskArgs.amount} to ${taskArgs.to}  successful`);
};
