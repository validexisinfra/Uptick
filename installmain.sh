#!/bin/bash

set -e

GREEN="\e[32m"
RED="\e[31m"
NC="\e[0m"

print() {
  echo -e "${GREEN}$1${NC}"
}

print_error() {
  echo -e "${RED}$1${NC}"
}

read -p "Enter your node MONIKER: " MONIKER
read -p "Enter your custom port prefix (e.g. 16): " CUSTOM_PORT

print "Installing Uptick Node with moniker: $MONIKER"
print "Using custom port prefix: $CUSTOM_PORT"

print "Updating system and installing dependencies..."
sudo apt update
sudo apt install -y curl git build-essential lz4 wget

sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.23.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
echo "export PATH=$PATH:/usr/local/go/bin:/usr/local/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile

cd $HOME
rm -rf uptick
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout v0.2.19
make install

uptickd config chain-id uptick_117-1
uptickd config keyring-backend file
uptickd config node tcp://localhost:${CUSTOM_PORT}657
uptickd init $MONIKER --chain-id uptick_117-1

wget -O $HOME/.uptickd/config/genesis.json https://server-1.itrocket.net/mainnet/uptick/genesis.json
wget -O $HOME/.uptickd/config/addrbook.json  https://server-1.itrocket.net/mainnet/uptick/addrbook.json

SEEDS="e71bae28852a0b603f7360ec17fe91e7f065f324@uptick-mainnet-seed.itrocket.net:35656"
PEERS="dd482d080820020b144ca2efaf128d78261dea82@uptick-mainnet-peer.itrocket.net:10656,5e5f399cc9dd01ec44f0af2b1bba1440d5ecf994@37.27.131.251:35656,f05733da50967e3955e11665b1901d36291dfaee@65.108.195.30:21656,ee045c74c0678f1122650a3a5223923977cae1b3@65.109.93.152:30656,37e4491bd756cf0ae5281c6f0da4bdcefe723eba@135.181.109.175:15656,fadab3eb04ebb651644ba15bb8f532bb509fe0f7@95.216.202.212:27656,71f6b583a3e4ed79e6f564c57b2a67cdd05fe6a4@65.21.63.225:11556,10da0790087be7a41d1fded3727aa5364b726416@157.90.0.102:26656,14ca9d73314dd519bc0b0be8511c88f85fe6873e@46.4.81.204:17656,7a320021212d346a7e8bfd5926feb4b307e7f69b@5.9.147.22:26556,16fa4bbce20eb8b7102ac751987d66380b2707fc@88.99.68.249:15956,9ce22beafb710cda061dfebb14074a25ef3385b0@185.180.222.190:16656,517d7d453dd116b1c2b990e5eb5ccc4a4bb4d00c@94.130.138.48:31656,0cba8f6d9de4a017c382f57e5389f0ad138605f4@144.76.74.73:15956,c21eeb897d3fa45a81772b56038045d1d873252e@142.132.199.236:30656,34d86f3a8dfce7d8b615563c587433c65792f104@185.219.142.221:15656,bd2e1f218fde74045fbcff3fe36c467e7f05d7a3@198.244.165.50:21656,d437de9c0b06e4270206a789fcefbb75973a5bb8@167.235.2.246:43756,90c0c03d27e5b4354bffb709d28340f2657ca1c7@138.201.121.185:26679,ccb5574802476107befcfdb79867a942008fdd82@167.235.9.223:61156,15267169f8eb4778a19b48360e5bcb519d923daa@207.121.13.108:35656,6efbb5b3a57a285a807c6ac9390278bfd58a8378@65.21.172.60:16656,b2bcb66f270153791b19e16ff23ddfec096f7097@142.132.202.50:41656,ea9c7688fa12f96c13cb37692fb129a780f6660e@65.109.88.251:11096,8fbfb8bff5d783df53b9ee95ab6b6e7ff708f280@65.108.134.215:32656,2cc70e14c1cdb94edce3a9f8aa149880331af29d@212.23.222.109:26356,bd954fa570942632c87867690bc7e6108a1527aa@65.109.70.100:27656,e75bcaf0cf2d5dce359c1258121ecaa6d5b41991@144.76.29.90:60956,c20c3532f30adcc3df74e563c32ef318c845bf83@157.180.3.171:656,513024d96e6d89c415952ec64eb8d67441247efa@38.242.149.183:26656,e8704845eaa0f3d39fcdc9c4065f3beb344384db@142.132.152.46:27656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.uptickd/config/config.toml

sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.0025auptick"|g' $HOME/.uptickd/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.uptickd/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.uptickd/config/config.toml

sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.uptickd/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.uptickd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.uptickd/config/app.toml

sed -i.bak -e "s%:26658%:${CUSTOM_PORT}658%g;
s%:26657%:${CUSTOM_PORT}657%g;
s%:26656%:${CUSTOM_PORT}656%g;
s%:6060%:${CUSTOM_PORT}060%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${CUSTOM_PORT}56\"%;
s%:26660%:${CUSTOM_PORT}660%g" $HOME/.uptickd/config/config.toml

sed -i.bak -e "s%:1317%:${CUSTOM_PORT}317%g;
s%:8080%:${CUSTOM_PORT}080%g;
s%:9090%:${CUSTOM_PORT}090%g;
s%:9091%:${CUSTOM_PORT}091%g;
s%:8545%:${CUSTOM_PORT}545%g;
s%:8546%:${CUSTOM_PORT}546%g" $HOME/.uptickd/config/app.toml


sudo tee /etc/systemd/system/uptickd.service > /dev/null <<EOF
[Unit]
Description=Uptick node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.uptickd
ExecStart=$(which uptickd) start --home $HOME/.uptickd --chain-id uptick_117-1
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

print "Downloading snapshot..."
uptickd tendermint unsafe-reset-all --home $HOME/.uptickd
if curl -s --head curl https://server-1.itrocket.net/mainnet/uptick/uptick_2025-05-20_11787924_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-1.itrocket.net/mainnet/uptick/uptick_2025-05-20_11787924_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.uptickd
    else
  echo "no snapshot found"
fi

sudo systemctl daemon-reload
sudo systemctl enable uptickd
sudo systemctl restart uptickd

print "✅ Setup complete. Use 'journalctl -u uptickd -f -o cat' to view logs"
