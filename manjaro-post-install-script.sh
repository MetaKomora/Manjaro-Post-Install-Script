#!/bin/bash

#### Functions ####

# Check if pamac installed, if isn't, install it
function checkPamac()
{
    check=$(pacman -Qs pamac-gtk)
    if [ ! -n "$check" ]; then
    printf "\nPamac is not installed, installing right now\n"; sleep 2
    pacman -S pamac-gtk --noconfirm
    fi
}

# Check if themes are on ~/.themes and ~/.icons
function checkThemes()
{
    themes=$(ls -A $HOME/.themes)
    icons=$(ls -A $HOME/.icons)
    if [ ! -n "$themes" ] && [  ! -n "$icons" ]; then
    printf "You don't have themes installed, installing right now"; sleep 2
    else
    printf ""; sleep 2
    fi
}

# Check if user is root, if not, login as root
function checkUser()
{
    if [ "$UID" != "0" ]; then
    printf "\nYou need to log as root to continue\n"; sleep 2
    sudo -i
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
    pamac build xfce4-dockbarx-plugin xfce4-windowck-plugin --no-confirm

    # Remove double menus when using Vala Panel Appmenu
    xfconf-query -c xsettings -p /Gtk/ShellShowsMenubar -n -t bool -s true
    xfconf-query -c xsettings -p /Gtk/ShellShowsAppmenu -n -t bool -s true

    # XFCE Icons, GTK, WM and Notify themes
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Xenlism-Wildfire"
    xfconf-query -c xsettings --create -p /Net/FallbackIconTheme -t "string" -s "Papirus-Maia"
    xfconf-query -c xsettings -p /Net/ThemeName -s "Flat-Remix-GTK-Green-Darker"
    xfconf-query -c xfwm4 -p /general/theme -s "Flat-Remix-GTK-Green-Dark"
    xfconf-query -c xfce4-notifyd -p /theme -s "Plata"

    # Remove unnecessary stuff
    sudo pamac remove pidgin blueman xfce4-taskmanager xfburn xfce4-dict htop hexchat vulkan-radeon lib32-vulkan-radeon hplip --no-confirm

}

# Programs for KDE environment
function KDE()
{
    # Install packages for global menu on KDE and pamac
    sudo pacman -S appmenu-gtk-module libdbusmenu-glib pamac-gtk --noconfirm

    # Remove unnecessary stuff
    sudo pamac remove yakuake spectacle skanlite vulkan-radeon lib32-vulkan-radeon konversation kget hplip bluedevil octopi --no-confirm
}


#### ZRAM ####

# Enable zram module
sudo modprobe zram
echo "zram" | sudo tee -a /etc/modules-load.d/zram.conf

# Configure the number of /dev/zram devices you want
echo "options zram num_devices=2" | sudo tee -a /etc/modprobe.d/zram.conf

# Create a udev rule
echo 'KERNEL=="zram0", ATTR{disksize}="1G" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' | sudo tee -a /etc/udev/rules.d/99-zram.rules
echo 'KERNEL=="zram1", ATTR{disksize}="1G" RUN="/usr/bin/mkswap /dev/zram1", TAG+="systemd"' | sudo tee -a /etc/udev/rules.d/99-zram.rules

# Add /dev/zram to your fstab
echo "/dev/zram0 none swap defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/zram1 none swap defaults 0 0" | sudo tee -a /etc/fstab

# Alter swappiness priority to 10
echo "vm.swappiness = 10" | sudo tee -a /etc/sysctl.d/99-sysctl.conf



#### Program Installation ####

# Switching branch to testing
sudo -v && sudo pacman-mirrors --api --set-branch testing

# Change mirrors, update repositories and upgrade packages if needed
sudo pacman-mirrors -c Brazil,United_States && sudo pamac update --force-refresh --no-confirm

# Check Desktop Environment
if [ $XDG_CURRENT_DESKTOP == "XFCE" ]; then
printf "\nYou are using XFCE, configuring for XFCE...\n"; sleep 2
XFCE
else
printf "\nYou are using KDE, configuring for KDE...\n"; sleep 2
KDE
fi

# Themes
sudo pamac install arc-gtk-theme adapta-gtk-theme materia-gtk-theme paper-icon-theme-git --no-confirm
