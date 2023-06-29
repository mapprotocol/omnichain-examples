const { OMNICHAIN_SALT,DEPLOY_FACTORY} = process.env;

task("senCrossToken",
    "deploy omniDictionary",
    require("./senCrossToken")
)

task("setTrustedList",
    "deploy omniDictionary",
    require("./setTrustedList")
)

task("deployDictionary",
    "deploy omniDictionary",
    require("./OmniDictionary/deployDictionary")
)
    .addParam("mos", "mos address")

task("factoryDeploy",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./OmniDictionary/factoryDeploy")
)
    .addOptionalParam("mos", "mos address", "0x8c3ccc219721b206da4a2070fd96e4911a48cb4f",types.string)
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)

task("getDictionary",
    "Gets the value of the current key",
    require("./OmniDictionary/getDictionary")
)
    .addParam("address", "omniDictionary contract address")
    .addParam("key", "Query key")

task("sendDictionary",
    "send dictionary key-value",
    require("./OmniDictionary/sendDictionary")
)
    .addParam("address", "echo omniDictionary address")
    .addParam("key", "key")
    .addParam("value", "value")
    .addParam("chainid", "The cross-chain chainId of the message")
    .addParam("target", "Target chain execution address")


task("addRemoteCaller",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./OmniDictionary/addRemoteCaller")
)
    .addParam("fromchain", "mos address")
    .addOptionalParam("omni", "deploy contract salt","0xB53C1Fb399072705444c320aAFb77D47300d5Ff2" , types.string)
    .addOptionalParam("tag", "deploy contract salt",true , types.boolean)
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)

task("setMapoService",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./OmniDictionary/setMapoService")
)
    .addParam("mos", "mos address")
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)


task("setWhiteList",
    "Deploy the upgradeable MOS contract and initialize it",
    require("./OmniDictionary/setWhiteList")
)
    .addParam("mos", "mos address")
    .addOptionalParam("salt", "deploy contract salt",OMNICHAIN_SALT , types.string)
    .addOptionalParam("factory", "mos contract address",DEPLOY_FACTORY , types.string)