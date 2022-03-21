# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# Lint & format
fmt			:; yarn fmt
lint		:; yarn lint

# Build & test
build		:; forge build --root .
clean		:; rm -rf cache && rm -rf out && forge clean --root .
gas			:; forge test --root . --gas-report
snapshot	:; forge snapshot --root .
test		:; forge test --root .
logs		:; forge test -vv --root .
trace		:; forge test -vvv --root .
trace_all	:; forge test -vvvv --root .
trace_setup	:; forge test -vvvvv --root .

# Transactions
# Any env var can be set in .env or in the command (e.g. VALUE="123" cast call ...)
# Use $ETH_FROM, $KEYSTORE_PASSWORD, $KEYSTORE_PATH for own keystore
# $VALUE is parsed as hexadecimal

# Call
# make call <TO> <SIG> [ARGS]...
call		:; cast ${MAKECMDGOALS} --rpc-url ${ETH_RPC_URL} --keystore ${KEYSTORE_PATH} --password ${KEYSTORE_PASSWORD} --from ${ETH_FROM}

# Send
# make send <TO> <SIG> [ARGS]...
send		:; cast ${MAKECMDGOALS} --rpc-url ${ETH_RPC_URL} --keystore ${KEYSTORE_PATH} --password ${KEYSTORE_PASSWORD} --from ${ETH_FROM} --value ${ETH_VALUE}

# Deploy
# $ARG<N> for any constructor arguments
# make create <CONTRACT_NAME>
create		:; make build -s && forge ${MAKECMDGOALS} --rpc-url ${ETH_RPC_URL} --keystore ${KEYSTORE_PATH} --password ${KEYSTORE_PASSWORD} --from ${ETH_FROM} --constructor-args ${ARG_1} --constructor-args ${ARG_2} --constructor-args ${ARG_3}
