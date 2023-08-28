#!/bin/bash
setting_sshd_config() {
	echo "Setting sshd_cofnig " ;
	sudo cp  /etc/ssh/sshd_config  /etc/ssh/sshd_config.backup ;
	
	echo "Setting Port number 22 --> 4222 ";
    sudo sed -i 's/Port/#Port/g'                              /etc/ssh/sshd_config  ;
	sudo bash -c ' echo "### etting Port number 4222 " >> /etc/ssh/sshd_config ';
	sudo bash -c ' echo "Port 4222"                    >> /etc/ssh/sshd_config ';

	echo "PasswordAuthentication no --> yes ";
	sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config ;	

	sudo /etc/init.d/sshd  restart ;
	sudo service sshd      restart ;
}
setting_sshd_config ; 
exit 0;
