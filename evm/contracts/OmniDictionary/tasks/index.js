const { OMNICHAIN_SALT,DEPLOY_FACTORY} = process.env;

task("deployDictionary",
    "deploy omniDictionary",
    require("./deployDictionary")
)
    .addParam("mos", "mos address")

task("factoryDeploy",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./factoryDeploy")
)
    .addOptionalParam("mos", "mos address", "0xcDf0b81Fea68865158fa00Bd63627d6659A1Bf69",types.string)
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)

task("getDictionary",
    "Gets the value of the current key",
    require("./getDictionary")
)
    .addParam("address", "omniDictionary contract address")
    .addParam("key", "Query key")

task("sendDictionary",
    "send dictionary key-value",
    require("./sendDictionary")
)
    .addParam("address", "echo omniDictionary address")
    .addParam("key", "key")
    .addParam("value", "value")
    .addParam("chainid", "The cross-chain chainId of the message")
    .addParam("target", "Target chain execution address")


task("addRemoteCaller",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./addRemoteCaller")
)
    .addParam("fromchain", "mos address")
    .addOptionalParam("omni", "deploy contract salt","0xce0D71489472B8BDE73f2B7C6808986611EEd3EF" , types.string)
    .addOptionalParam("tag", "deploy contract salt",true , types.boolean)
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)

task("setMapoService",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./setMapoService")
)
    .addParam("mos", "mos address")
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)


task("setWhiteList",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./setWhiteList")
)
    .addParam("mos", "mos address")
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)