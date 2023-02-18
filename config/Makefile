requisites:
	 scp -i ~/.ssh/gcp ~/.ssh/gcp  yomali@35.242.137.109:/home/yomali/.ssh/id_rsa
	 ssh yomali@35.242.137.109 -i ~/.ssh/gcp "chmod 400 /home/yomali/.ssh/id_rsa"

copy:
	 scp -i ~/.ssh/gcp -r * yomali@35.242.137.109:/home/yomali/

info:
	 ssh yomali@35.242.137.109 -i ~/.ssh/gcp "ansible --version"
	 ssh yomali@35.242.137.109 -i ~/.ssh/gcp "ls"
	 
mysql: info
	 ssh yomali@35.242.137.109 -i ~/.ssh/gcp "ansible-playbook -i inventory mysql.yaml"

haproxy: info
	 ssh yomali@35.242.137.109 -i ~/.ssh/gcp "ansible-playbook -i inventory haproxy.yaml"
