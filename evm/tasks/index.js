


task("deployDictionary",
    "deploy omniDictionary",
    require("./deployDictionary")
)
    .addParam("mos", "mos address")

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

