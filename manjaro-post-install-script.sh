#!/bin/bash

#### Functions ####

# Check if pamac installed, if isn't, install it
function checkPamac()
{
    check=$(pacman -Qs pamac-gtk)
    if [ -n "$check" ]; then
    printf "Pamac is installed"
    sleep 2
    else
    printf "Pamac is not installed, installing"
    sleep 2
    pacman -S pamac-gtk --noconfirm
    fi
}

# Configurations and programs for XFCE environment
function XFCE()
{
    # Window Manager Tweaks > Accessibility > Hide frame of windows when maximized
    # Hide title of windows when maximized
    xfconf-query -c xfwm4 -p /general/titleless_maximize -s true
    xfconf-query -c xfwm4 -p /general/borderless_maximize -s true

    # Window Manager > Button layout
    xfconf-query -c xfwm4 -p /general/button_layout -s 'CHM|'
    xfconf-query -c xsettings -p /Gtk/DecorationLayout -s "close,minimize,maximize:"

    # Vala Panel Appmenu (global menu for XFCE), 
    # Dockbarx (taskbar), 
    # Windowck (window header buttons)
    sudo pamac install appmenu-gtk-module vala-panel-appmenu-registrar vala-panel-appmenu-xfce-gtk3 --no-confirm
    pamac build dockbarx xfce4-dockbarx-plugin --no-confirm

    # Remove double menus when using Vala Panel Appmenu
    xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true
    xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true

    # XFCE Icons, GTK, WM and Notify themes
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Xenlism-Wildfire"
    xfconf-query -c xsettings --create -p /Net/FallbackIconTheme -t "string" -s "Papirus-Maia"
    xfconf-query -c xsettings -p /Net/ThemeName -s "Flat-Remix-GTK-Green-Darker"
    xfconf-query -c xfwm4 -p /general/theme -s "Flat-Remix-GTK-Green-Darker"
    xfconf-query -c xfce4-notifyd -p /theme -s "Plata-Lumine"

    # Session and Startup > Advanced > Launch GNOME services on startup
    xfconf-query -c xfce4-session -p /compat/LaunchGNOME -s false

    # Remove unnecessary stuff
    sudo pamac remove pidgin blueman xfce4-taskmanager xfburn xfce4-dict htop hexchat vulkan-radeon lib32-vulkan-radeon hplip --no-confirm

}

# Programs for KDE environment
function KDE()
{
    # Install packages for global menu on KDE and pamac
    sudo pacman -S appmenu-gtk-module libdbusmenu-glib pamac-cli pamac-gtk --noconfirm

    # Remove unnecessary stuff
    sudo pamac remove yakuake spectacle skanlite vulkan-radeon lib32-vulkan-radeon konversation kget hplip bluedevil octopi --no-confirm
}

#### ZRAM ####

# Login as root
sudo -i

# Enable zram module
modprobe zram
echo zram >> /etc/modules-load.d/zram.conf

# Configure the number of /dev/zram devices you want
echo "options zram num_devices=2" >> /etc/modprobe.d/zram.conf

# Create a udev rule
echo 'KERNEL=="zram0", ATTR{disksize}="1G" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules
echo 'KERNEL=="zram1", ATTR{disksize}="1G" RUN="/usr/bin/mkswap /dev/zram1", TAG+="systemd"' >> /etc/udev/rules.d/99-zram.rules

# Add /dev/zram to your fstab
echo "/dev/zram0 none swap defaults 0 0" >> /etc/fstab
echo "/dev/zram1 none swap defaults 0 0" >> /etc/fstab

# Alter swappiness priority to 10
echo "vm.swappiness = 10" >> /etc/sysctl.d/99-sysctl.conf

# Exiting root
exit


#### Program Installation ####

# Change to fasttrack mirrors
sudo pacman-mirrors -f 5

# Check Desktop Environment
sudo -v
interface=$(echo $XDG_CURRENT_DESKTOP)
if [ $interface = "XFCE" ]; then
printf "\nYou are using XFCE\n"
sleep 2
XFCE
else
printf "\nYou are using KDE\n"
sleep 2
KDE
fi

# Update Manjaro repositories
sudo pamac update --force-refresh

# Themes
sudo pamac install arc-gtk-theme adapta-gtk-theme materia-gtk-theme paper-icon-theme-git