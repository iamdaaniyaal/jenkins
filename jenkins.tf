provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
  region      = "${var.region}"
}

resource "google_compute_address" "jenkinsip" {
  name   = "${var.jenkins_instance_ip_name}"
  region = "${var.jenkins_instance_ip_region}"
}

# data "template_file" "mydeamon" {
#   # template = "${file("conf.wp-config.php")}"

#   template = templatefile("${path.module}/mydeamon.json", { jenkinsip = "${google_compute_address.jenkinsip.address}" })

# }

resource "google_compute_instance" "jenkins" {
  name         = "${var.instance_name}"
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"

  tags        = ["name", "jenkins", "http-server"]
  description = "${google_compute_address.jenkinsip.address}"

  boot_disk {
    initialize_params {
      image = "centos-7-v20180129"
    }
  }

  // Local SSD disk
  #scratch_disk {
  #}


 network_interface {
    network    = "${var.sonarvpc}"
    subnetwork = "${var.sonarsub}"

    access_config {
      // Ephemeral IP

      nat_ip       = "${google_compute_address.jenkinsip.address}"
      network_tier = "PREMIUM"
    }
  }




  # provisioner "file" {
  #   content     = "${data.template_file.jenkins.rendered}"
  #   destination = "/tmp/jenkins.sh"

  #   connection {
  #     type     = "ssh"
  #     user     = "root"
  #     password = "root123"
  #     # host     = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
  #     host = "${google_compute_address.jenkinsip.address}"
  #   }
  # }


#   provisioner "file" {
#     content     = "${data.template_file.mydeamon.rendered}"
#     destination = "/tmp/mydeamon.json"

#     connection {
#       type     = "ssh"
#       user     = "root"
#       password = "root123"
#       # host     = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
#       host = "${google_compute_address.jenkinsip.address}"
#     }
#   }


  # provisioner "file" {
  #   content     = "${data.template_file.mvn_sonar_settings.rendered}"
  #   destination = "/tmp/mvn_sonar_settings.xml"

  #   connection {
  #     type     = "ssh"
  #     user     = "root"
  #     password = "root123"
  #     # host     = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
  #     host = "${google_compute_address.jenkinsip.address}"
  #   }
  # }


  # provisioner "remote-exec" {
  #   inline = [
  #     # "sudo su - test",
  #     # "sudo -s",
  #     "sudo chmod 777 /tmp/jenkins.sh",
  #     "sudo sh /tmp/jenkins.sh",
  #   ]


  #   connection {
  #     type     = "ssh"
  #     user     = "root"
  #     password = "root123"
  #     # host     = "${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}"
  #     host = "${google_compute_address.jenkinsip.address}"
  #   }
  # }
  metadata = {
    name = "jenkins"
  }


  # metadata_startup_script = "sudo yum update -y; sudo yum install wget -y; sudo  echo \"root123\" | passwd --stdin root; sudo  mv /etc/ssh/sshd_config  /opt; sudo touch /etc/ssh/sshd_config; sudo echo -e \"Port 22\nHostKey /etc/ssh/ssh_host_rsa_key\nPermitRootLogin yes\nPubkeyAuthentication yes\nPasswordAuthentication yes\nUsePAM yes\" >  /etc/ssh/sshd_config; sudo systemctl restart  sshd;sudo useradd test; sudo echo  -e \"test    ALL=(ALL)  NOPASSWD:  ALL\" >> /etc/sudoers; sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo; sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key; sudo yum install jenkins maven google-cloud-sdk kubectl -y; sudo  wget -O  /opt/docker.sh  https://get.docker.com && sudo chmod 755 /opt/docker.sh; sudo wget -P /opt/  https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip; sudo unzip /opt/sonar-scanner-cli-3.3.0.1492-linux.zip -d /opt  &&  sudo mv /opt/sonar-scanner-3.3.0.1492-linux  /opt/sonar-scanner"
  metadata_startup_script = "sudo yum update -y; sudo yum install wget -y; sudo  echo \"root123\" | passwd --stdin root; sudo  mv /etc/ssh/sshd_config  /opt; sudo touch /etc/ssh/sshd_config; sudo echo -e \"Port 22\nHostKey /etc/ssh/ssh_host_rsa_key\nPermitRootLogin yes\nPubkeyAuthentication yes\nPasswordAuthentication yes\nUsePAM yes\" >  /etc/ssh/sshd_config; sudo systemctl restart  sshd;sudo useradd test; sudo echo  -e \"test    ALL=(ALL)  NOPASSWD:  ALL\" >> /etc/sudoers; sudo yum install git -y; sudo git clone https://github.com/iamdaaniyaal/jenkins.git; cd /jenkins; sudo chmod 777 *.*; sudo sh jenkins.sh;"
  # metadata_startup_script = "sudo yum update -y; sudo yum install git -y; sudo git clone https://github.com/iamdaaniyaal/devops.git; sudo chmod 777 *.*; sudo sh jenkins.sh;"
}
