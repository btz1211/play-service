#!/bin/bash

#Install buildkite
sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
sudo apt-get update && sudo apt-get install -y buildkite-agent
sudo sed -i "s/xxx/1fe00a68d2b0a599eb2dac11a2ea21481a696ef651c32aebdb/g" /etc/buildkite-agent/buildkite-agent.cfg
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent

#run the rest of the commands as the buildkite-agent user
sudo usermod -a -G sudo buildkite-agent
sudo usermod -a -G google-sudoers buildkite-agent


#install sbt
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt <<-EOF
yes
EOF

#install docker
sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y docker-engine
sudo usermod -aG docker buildkite-agent

#install kubernetes
sudo su buildkite-agent
cd ~
sudo curl -sS https://get.k8s.io | bash
