#!/bin/bash

#Install buildkite
sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
sudo apt-get update && sudo apt-get install -y buildkite-agent
sudo sed -i "s/xxx/f081f500c8eb4e6c3d254094bf30dc9ec950f47def0e25c8cd/g" /etc/buildkite-agent/buildkite-agent.cfg
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent

# install java
sudo apt-get install default-jdk <<-EOF
yes
EOF

# #install sbt
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
sudo usermod -a -G docker buildkite-agent
sudo service docker stop
sudo service docker start

#install kubernetes
sudo curl -sS https://get.k8s.io | bash
find kubernetes -type d -exec chmod +rx {} \;
find kubernetes -type f -exec chmod +rx {} \;
echo "echo 'PATH=$HOME/kubernetes/client/bin:$PATH' >> /etc/environment" > add_kubectl.sh
sudo bash add_kubectl.sh

#add user to sudoer without password
sudo adduser buildkite-agent sudo
echo "echo 'buildkite-agent ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers" >> add_to_sudoers.sh
sudo bash add_to_sudoers.sh

#restart instance
gcloud compute instances reset [instance-name] --zone [zone]
