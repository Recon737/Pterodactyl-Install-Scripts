# Optimizes APT mirrors, installs qemu-guest-agent, installs Wings Dependencies, 
# makes additional configuration changes outlined at https://pterodactyl.io/wings/1.0/installing.html, and downloads Wings
# then reboots the system

# Install misc dependencies
apt update
apt install -y netselect-apt qemu-guest-agent
#turn on qemu-guest-agent
systemctl enable --now qemu-guest-agent
# Optimize apt mirrors
netselect-apt -nc US -o /etc/apt/sources.list
#insert default worldwide Debian mirror as a fallback
sed -i '/^deb/a\deb http://deb.debian.org/debian bullseye main' /etc/apt/sources.list
# Upgrade packages using new mirrors
apt update
apt upgrade -y

# DOCKER INSTALL FROM DOCS.DOCKER.COM

# Remove conflicting packages
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc;
do 
apt remove $pkg;
done

# Install docker with apt

# Add Docker's official GPG key:
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Install the Docker Packages
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Make Docker start on boot
systemctl enable --now docker

# Modify grub to allow Docker to setup swap space
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/^\(GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)\)"/\1 swapaccount=1"/' /etc/default/grub
update-grub

# Create the Wings base directory and download the executable
mkdir -p /etc/pterodactyl
curl -L -o /bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /bin/wings

# Reboot to apply grub changes
reboot
