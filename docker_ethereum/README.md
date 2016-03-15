
### Geth, Solidity, node and web3

### Build image
```
./build
```

### Create and run temp container
```
./run
```

```
screen -s /bin/bash

# start geth with http-rpc
geth --datadir docker/data/ --rpc

# test web3
node docker/examples/last_block.js
node docker/examples/token.js
```

### Old
```
cd docker/x/
node server.js 

# attach to geth with admin, personal etc loaded, 
geth --ipcpath docker/data/geth.ipc attach --solc $(which solc)

# NODE docker/web/server.js 
# MORE
# RUN n  ~/.ethereum
# geth --ipcpath ./docker/data/geth.ipc --exec 'eth.getBlock("latest").number' attach
# etc
# geth --solc /home/ethereum/cpp-ethereum/build/solc/solc

```

