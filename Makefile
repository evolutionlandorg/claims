all    :; source .env.local && dapp --use solc:0.8.11 build
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create Claims
