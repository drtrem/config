#!/bin/bash

#Добавляем репозитории
add-apt-repository -y ppa:videolan/stable-daily
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add
bash -c 'echo "deb http://www.bchemnet.com/suldr/ debian extra" >> /etc/apt/sources.list'
apt-add-repository -y ppa:jeffreyratcliffe/ppa "deb http://archive.canonical.com/ $(lsb_release -sc) partner"
apt-add-repository -y ppa:teejee2008/ppa
dpkg --add-architecture i386
apt-get -y update
aptitude -y upgrade
apt-get -fy install

Подготовка к старту
mkdir -p /temp
cp mate.tar.gz /temp
cd /temp
tar -xvf mate.tar.gz

#Установка из репозиториев
echo ""
aptitude -y install ssh mc remmina remmina-plugin-rdp gscan2pdf conky-manager puppet rar vlc
apt-get -fy install

#Ставим пакеты из deb

dpkg -i /temp/mate/crossover_16.0.0-1.deb
sh -c "apt-get update; apt-get install libnss-mdns:i386"
cp /temp/mate/winewrapper.exe.so /opt/cxoffice/lib/wine/winewrapper.exe.so

dpkg -i /temp/mate/microsoft+office+2010_15.3.0-1_all.deb

dpkg -i /temp/mate/master-pdf-editor-3.7.10_amd64.deb

dpkg -i /temp/mate/skypeforlinux-64-alpha.deb

dpkg -i /temp/mate/teamviewer_12.0.71510_i386.deb
apt-get -fy install
dpkg -i /temp/mate/teamviewer_12.0.71510_i386.deb

#Шрифты
cp -r /temp/mate/myriadpro/ /usr/share/fonts/opentype/
apt-get -y install msttcorefonts
fc-cache -fv

#sshd config
cp /temp/mate/sshd_config /etc/ssh/sshd_config

#Общий рабочий стол
cp -Rfb /temp/mate/skel/* /temp/mate/skel/.[a-zA-Z0-9]* /etc/skel

#install driver
adduser user lp
apt-get -y --allow-unauthenticated --force-yes install suld-driver-4.01.17
dpkg --configure -a
apt-get -fy install
apt-get -y --allow-unauthenticated --force-yes install suld-driver-4.01.17

sed -i "s/15/600/" /usr/share/mdm/html-themes/Mint-X/slideshow.conf

#del xplayer
apt-get remove -y xplayer

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
sed -i "s/test/$username/" "/home/$username/.conky/conky-startup.sh"
sed -i "s/test/$username/" "/home/$username/.config/autostart/conky.desktop"

#samba
apt-get -y install samba
apt-get -y install libnss-winbind
cp /temp/mate/nsswitch.conf /etc/nsswitch.conf
cp /temp/mate/smb.conf /etc/samba/smb.conf
/etc/init.d/samba restart
 
#puppet
sed -i '/\/var\/log\/puppet/a \server=foreman.dsdo.dn.ua' /etc/puppet/puppet.conf
sed -i 's/templatedir/#templatedir/' /etc/puppet/puppet.conf
systemctl start puppet
systemctl enable puppet
puppet agent -t
puppet agent --enable
puppet agent -t
puppet resource service puppet ensure=running enable=true

#Шифрование под юзера.
echo "Password pod kogo book '18sgd' dlya encrypt"
cryptsetup luksAddKey /dev/sda5
