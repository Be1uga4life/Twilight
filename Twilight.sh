#!bin/bash
HostUser=$(who | sed 's/\s.*$//')
touch users.list | > users.list

echo "Users

Admins
" >> users.list
gedit users.list 2>/dev/null


echo -e "\e[95m------\e[94mUser Auditing\e[95m------\e[39m"

Users=$(awk '/^Admins/{f=0} /^.*Users/{f=1} f' users.list | sed 's/Users//' | xargs)
Admins=$(awk '/^Users/{f=0} /^.*Admins/{f=1} f' users.list | sed 's/Admins//' | sed "s/$HostUser//" | xargs)
VmUsers=$(awk -F ':' '$3>=1000 {print $1}' /etc/passwd | sed 's/nobody//' | xargs)

IFS=' ' read -r -a Users <<< "$Users"
IFS=' ' read -r -a Admins <<< "$Admins"
IFS=' ' read -r -a VmUsers <<< "$VmUsers"


DeletionComparison=("${Admins[@]}" "${Users[@]}")

#Users
for SysUser in "${VmUsers[@]}"
do	
	if [[ ! " ${DeletionComparison[*]} " =~ " ${SysUser} " ]]; then
		read -p "$SysUser is an unauthorized user, Delete? [y/n]: " answer
		if [ $answer == "y" ]
		then
			deluser $SysUser &>/dev/null
			echo -e "[\e[92mConfiguration Finished\e[39m] Removed Unauhtorized User $SysUser"
		fi
	fi
	
	elif [[ " ${SysUser[*]} " =~ " ${DeletionComparison} " ]]; then
		read -p "$SysUser hasn't been added, Add? [y/n]: " answer
		if [ $answer == "y" ]
		then
			useradd $SysUser &>/dev/null
			echo -e "[\e[92mConfiguration Finished\e[39m] Added user $SysUser"
		fi
	fi
done

mkdir UserFiles &> /dev/null
#Admins
for Config in "${Users[@]}"
do 
	echo $Config:CyberPatriot1! | sudo chpasswd -e 2> /dev/null
	usermod -s /bin/bash $Config 2> /dev/null
	chown $Config /home/$Config 2> /dev/null
	chmod 644 /home/$Config 2> /dev/null
	chage -m 7 -M 90 -W 14 $Config 2> /dev/null

	gpasswd -d $Config adm &> /dev/null
	gpasswd -d $Config sudo &> /dev/null
	
	mkdir /UserFiles/$DeleteMedia &> /dev/null
	mv /home/$Config/* /UserFiles/$DeleteMedia/ &> /dev/null
	chmod 777 UserFiles/$Config/$Config &> /dev/null
done

echo -e "[\e[92mConfiguration Finished\e[39m] Finished Common User Configurations"
for Config in "${Admins[@]}"
do 
	echo $Config:CyberPatriot1! | sudo chpasswd -e 2> /dev/null
	usermod -s /bin/bash $Config &> /dev/null 2> /dev/null
	chown $Config /home/$Config 2> /dev/null
	chmod 644 /home/$Config 2> /dev/null
	chage -m 7 -M 90 -W 14 $Config 2> /dev/null 

	usermod -a -G sudo $Config &> /dev/null
	usermod -a -G adm $Config &> /dev/null

	mkdir /UserFiles/$DeleteMedia &> /dev/null
	mv /home/$Config/* /UserFiles/$DeleteMedia/ &> /dev/null
	chmod 777 UserFiles/$Config/$Config &> /dev/null

done
echo -e "[\e[92mConfiguration Finished\e[39m] Finished Common Admins Configurations"

###### Account Policies ########
echo -e "\e[95m------\e[94mAccount Policies\e[95m------\e[39m"
unzip pam_secure.zip | cp -fR ./pam_secure.zip /etc/pam.d
cp SecureLoginDef /etc/login.defs
echo -e "[\e[92mConfiguration Finished\e[39m] Finished Login Configs"

###### Packages ########
echo -e "\e[95m------\e[94mPackages\e[95m------\e[39m"
> VmPackageList
> SusPackages

sudo apt list --installed 2>/dev/null | awk '{split($0, a, "/"); print a[1]}' >> VmPackageList

Pew=1
Omae=$(wc -l < VmPackageList)

for i in $(seq 1 $Omae);
do
	#Takes in an input from a line
	VmPackage=$(sed -n $Pew'p' VmPackageList) &> /dev/null
	if ! grep "$VmPackage" SafePackages &> /dev/null
	then
    		apt-cache search ^$VmPackage$ >> SusPackages
	fi
	Pew=$((Pew+1))
done

touch /etc/modprobe.d/modprobe.conf | > /etc/modprobe.d/modprobe.conf
echo "
install dccp /bin/false
install sctp /bin/false
install rds /bin/false
install tipc /bin/false
install n-hdlc /bin/false
install ax25 /bin/false
install netrom /bin/false
install x25 /bin/false
install rose /bin/false
install decnet /bin/false
install econet /bin/false
install af_802154 /bin/false
install ipx /bin/false
install appletalk /bin/false
install psnap /bin/false
install p8023 /bin/false
install p8022 /bin/false
install can /bin/false
install atm /bin/false
install cramfs /bin/false
install freevxfs /bin/false
install jffs2 /bin/false
install hfs /bin/false
install hfsplus /bin/false
install squashfs /bin/false
install udf /bin/false
install cifs /bin/true
install nfs /bin/true
install nfsv3 /bin/true
install nfsv4 /bin/true
install ksmbd /bin/true
install gfs2 /bin/true
install vivid /bin/false
install bluetooth /bin/false
install btusb /bin/false
install uvcvideo /bin/false
" >> /etc/modprobe.d/modprobe.conf


