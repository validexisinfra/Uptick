#!/bin/bash
cd $HOME
rm -rf uptick
git clone https://github.com/UptickNetwork/uptick.git
cd uptick
git checkout v0.2.19
make build
sudo mv $HOME/uptick/build/uptickd $(which uptickd)
sudo systemctl restart uptickd && sudo journalctl -u uptickd -f
