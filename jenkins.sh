sudo yum update -y
sudo systemctl stop firewalld && sudo systemctl disable firewalld
sudo echo 'export jenkinsip=`curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip`' >> ~/.bash_profile
sudo echo 'export sonarqubeip=`curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/description`' >> ~/.bash_profile
source ~/.bash_profile
sudo yum install epel-release -y 
sudo yum install java-1.8.0-openjdk  java-1.8.0-openjdk-devel  wget  unzip -y 
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install jenkins maven google-cloud-sdk kubectl -y
sudo echo "jenkins  ALL=(ALL)   NOPASSWD:  ALL" >> /etc/sudoers
sudo  wget -O  /opt/docker.sh  https://get.docker.com && sudo chmod 755 /opt/docker.sh 
sudo sh  /opt/docker.sh   &&  sudo usermod -aG  docker jenkins
# sudo cp /devops/mydaemon.json /etc/docker/daemon.json
# sudo sed -i 's/$jenkinsip/'$jenkinsip'/' /etc/docker/daemon.json
sudo su
sudo cat > /etc/docker/daemon.json << EOF
{
        "insecure-registries" : ["$jenkinsip"]
}
EOF
sudo sed -i 's/$jenkinsip/'$jenkinsip'/' /etc/docker/daemon.json
sudo  mv /usr/share/maven/conf/*  /mnt && sudo cp /devops/mvn_sonar_settings.xml /usr/share/maven/conf/settings.xml
sudo sed -i 's/$sonarqubeip/'$sonarqubeip'/' /usr/share/maven/conf/settings.xml 
sudo systemctl restart docker &&  sudo systemctl enable  docker
sudo systemctl restart jenkins &&  sudo systemctl enable  jenkins
sudo cp /var/lib/jenkins/secrets/initialAdminPassword /root/jenkins_pass
sudo wget -P /opt/  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip
sudo unzip /opt/sonar-scanner-cli-3.3.0.1492-linux.zip -d /opt  &&  sudo mv /opt/sonar-scanner-3.3.0.1492-linux  /opt/sonar-scanner
sudo echo "sonar.host.url=http://${sonarqubeip}" >> /opt/sonar-scanner/conf/sonar-scanner.properties
sudo cp /tmp/mydeamon.json /etc/docker/daemon.json
sudo chmod 777 /etc/docker/daemon.json
