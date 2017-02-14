#nameming
echo "Name PC and username"
read username
sed -i "s/mint_book/$username/" /etc/hosts
sed -i "s/mint_book/$username/" /etc/hosts
sed -i "s/mint_book/$username/" /etc/hostname
hostname $username
if [ $(id -u) -eq 0 ]; then
	read -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username -d /home/$username -s /bin/bash
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi

#prava na mount and sh
bash -c 'echo "'$username' ALL=(ALL) NOPASSWD: /bin/mount" >> /etc/sudoers'
bash -c 'echo "'$username' ALL=(ALL) NOPASSWD: /bin/sh" >> /etc/sudoers'

#add user groups
adduser $username dialout
adduser $username dip
adduser $username plugdev
adduser $username netdev
adduser $username lpadmin
adduser $username scanner

#conky
#sed -i "s/$(hostname)/$username/" "/home/$username/.conky/conky-startup.sh"
#sed -i "s/$(hostname)/$username/" "/home/$username/.config/autostart/conky.desktop"
sed -i "s/kireyko/$username/" "/home/$username/.conky/conky-startup.sh"
sed -i "s/kireyko/$username/" "/home/$username/.config/autostart/conky.desktop"
sed -i "s/test/$username/" "/home/$username/.conky/conky-startup.sh"
sed -i "s/test/$username/" "/home/$username/.config/autostart/conky.desktop"

puppet agent -t
