#!/bin/bash

#### Functions ####

# Check local themes and install if needed
function installThemes()
{
    themes=$(ls -A $HOME/.themes);
    icons=$(ls -A $HOME/.icons);
    if [ ! -n "$themes" ] && [  ! -n "$icons" ]; then

        printf "You don't have local themes, installing globally right now"; sleep 2
        zenity --warning --text "Type your password to proceed! ";
        pamac build flat-remix flat-remix-gtk xenlism-wildfire-icon-theme-git oranchelo-icon-theme --no-confirm
    
    else
        printf "you have themes"; sleep 2;
    fi
    sudo pamac install arc-gtk-theme adapta-gtk-theme materia-gtk-theme paper-icon-theme-git --no-confirm;


}

# Configurations and programs for XFCE environment
function XFCE()
{
    # Window Manager Tweaks > Accessibility > Hide frame of windows when maximized
    # Hide title of windows when maximized
    xfconf-query -c xfwm4 -p /general/titleless_maximize -s true
    #xfconf-query -c xfwm4 -p /general/borderless_maximize -s true

    # Window Manager > Button layout
    xfconf-query -c xfwm4 -p /general/button_layout -s 'CHM|O'
    #xfconf-query -c xsettings -p /Gtk/DecorationLayout -s "close,minimize,maximize:"

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

    # Set desktop wallpaper, hide icons
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorLVDS1/workspace0/last-image -s /home/mateus/Pictures/Wallpapers/Pexels/clouds-dawn-desktop-backgrounds-46253.jpg
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -s false
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -s false
    xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-trash -s false

    # Set keyboard shorcuts
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>t" -s xfce4-terminal
    xfconf-query -c xfce4-keyboard-shortcuts --create -p "/commands/custom/<Shift><Alt>k" --type string -s "flameshot gui"


    # Remove unnecessary stuff
    sudo pamac remove pidgin blueman xfce4-taskmanager xfburn xfce4-dict htop hexchat vulkan-radeon lib32-vulkan-radeon hplip --no-confirm

}

# Programs for KDE environment
function KDE()
{
    # Install packages for global menu on KDE and pamac
    sudo pamac install appmenu-gtk-module libdbusmenu-glib --noconfirm

    # Remove unnecessary stuff
    sudo pamac remove yakuake spectacle skanlite vulkan-radeon lib32-vulkan-radeon konversation kget hplip bluedevil --no-confirm
}


#### ZRAM ####

# do a function to check if zram is already configured on system
# if not returns zram: [ $(cat /etc/fstab | grep /dev/zram) ] || printf "\nInstalling ZRAM";

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

# Change mirrors and switch branch to testing
sudo pacman-mirrors -c Brazil,United_States && sudo -v && sudo pacman-mirrors --api --set-branch testing


# update repositories and upgrade packages if needed
sudo pamac update --force-refresh --no-confirm

# Check Desktop Environment
if [ $XDG_CURRENT_DESKTOP == "XFCE" ]; then
printf "\nYou are using XFCE, configuring for XFCE...\n"; sleep 2
XFCE
else
printf "\nYou are using KDE, configuring for KDE...\n"; sleep 2
KDE
fi
