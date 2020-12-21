#!/bin/bash

snapshotsdir=""
wallpapersdir""

# Low brightness level on i3 gaps
[[ "$XDG_SESSION_DESKTOP" == "i3" ]] && xrandr --output LVDS-1 --brightness 0.50

# if the mirrors branch is not testing, change to it
[[ $(pacman-mirrors -G) != "testing" ]] && sudo pacman-mirrors -c Brazil,United_States --api -B testing -P https -m rank

# if Desktop Environment is XFCE, install Dockbarx plugin
[[ "$XDG_SESSION_DESKTOP" == "xfce" ]] && {

	printf "\n\n\n\e[032;1mInstalling XFCE addons from AUR\e[m\n\n\n"; sleep 3;
	sudo pamac build xfce4-dockbarx-plugin --no-confirm

	# Set keyboard shorcuts
	xfconf-query -c xfce4-keyboard-shortcuts -n -p "/commands/custom/Super_L" -t string -s "xfce4-popup-whiskermenu";
	
	# Disable saved sessions
	xfconf-query -c xfce4-session -p /general/SaveOnExit -n -t bool -s false
	
	# Enable tap touchpad to click and change acceleration
	xfconf-query -c pointers -n -p /SynPS2_Synaptics_TouchPad/Properties/libinput_Tapping_Enabled -t int -s 1
	xfconf-query -c pointers -n -p /SynPS2_Synaptics_TouchPad/Acceleration -t double -s 9.0

	
	# Open new thunar instances as tabs, maximize Thunar, hide devices and etc
	xfconf-query -c thunar -n -p /misc-open-new-window-as-tab -t bool -s true;
	xfconf-query -c thunar -n -p /last-location-bar -t string -s ThunarLocationButtons;
	xfconf-query -c thunar -n -p /last-window-maximized -t bool -s true;
	xfconf-query -c thunar -n -p /misc-thumbnail-mode -t string -s THUNAR_THUMBNAIL_MODE_ALWAYS;

	
	# XFCE Icons, GTK and WM themes
	xfconf-query -c xsettings -p /Net/IconThemeName -s "Tela-circle-manjaro-dark";
	xfconf-query -c xsettings -n -p /Net/FallbackIconTheme -t "string" -s "Papirus";
	xfconf-query -c xsettings -p /Net/ThemeName -s "Dracula";
	xfconf-query -c xfwm4 -p /general/theme -s "Dracula";
	
	# Set panel transparency in percentage (the last option), position to bottom, lock the panel, Force panel redraw by toggling background-style
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/background-rgba -t double -t double -t double -t double -s 0.00 -s 0.00 -s 0.00 -s 0.00;
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/position-locked -t bool -s false;
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/position -t string -s "p=8;x=683;y=749";
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/position-locked -t bool -s true;
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/background-style -t int -s 0;
	xfconf-query -c xfce4-panel -n -p /panels/panel-1/background-style -t int -s 1;

	
	# Set keyboard shorcuts
	xfconf-query -c xfce4-keyboard-shortcuts -n -p "/commands/custom/<Shift><Alt>k" -t string -s "flameshot gui";
	xfconf-query -c xfce4-keyboard-shortcuts -n -p "/commands/custom/<Shift><Alt>d" -t string -s "flameshot gui -d 5000";
	
	# Set desktop wallpaper, hide icons
	xfconf-query -c xfce4-desktop -n -p /backdrop/screen0/monitorLVDS-1/workspace0/last-image -t string -s "$wallpapersdir"/Wallhaven/wallhaven-13vym3.jpg;
	xfconf-query -c xfce4-desktop -n -p /desktop-icons/style -t int -s 0;
	
	# Center all application windows
	xfconf-query -c xfwm4 -n -p /general/placement_mode -t string -s "center";
	xfconf-query -c xfwm4 -n -p /general/placement_ratio -t int -s "100";
	xfconf-query -c xfwm4 -n -p /general/show_dock_shadow -t bool -s false;
	
	# Enable notifications log, log level "always"
	xfconf-query -c xfce4-notifyd -n -p /notification-log -t bool -s true;
	xfconf-query -c xfce4-notifyd -n -p /log-level -t int -s 1;
	xfconf-query -c xfce4-notifyd -n -p /log-level-apps -t int -s 0;
	
	# Auto mount drives and media
	xfconf-query -c thunar-volman -n -p /automount-drives/enabled -t bool -s true;
	xfconf-query -c thunar-volman -n -p /automount-media/enabled -t bool -s true;
	
	# When a window raises itself, switch to window's workspace
	xfconf-query -c xfwm4 -n -p /general/activate_action -t string -s switch;
	
	# Settings Manager > Appearance > Fonts > Default Font
	xfconf-query -c xsettings -n -p /Gtk/FontName -t string -s "DejaVu Sans Semi-Condensed 10"
	
	# Settings Manager > Appearance > Fonts > Default Monospace Font
	xfconf-query -c xsettings -n -p /Gtk/MonospaceFontName -t string -s "DejaVu Sans Mono 10"
	
	# Settings Manager > Window Manager > Title Font
	xfconf-query -c xfwm4 -n -p /general/title_font -t string -s "DejaVu Sans Bold 9"
	
	# Settings Manager > Window Manager > Button Layout
	xfconf-query -c xfwm4 -n -p /general/button_layout -t string -s "O|HMC"
	
	# xfce4-screensaver inhibit screensaver for fullscreen applications, set personal slideshow and add directory location, set idle activation delay
	xfconf-query -c xfce4-screensaver -n -p /saver/enabled -t bool -s true
	xfconf-query -c xfce4-screensaver -n -p /saver/idle-activation/delay -t int -s 5
	xfconf-query -c xfce4-screensaver -n -p /saver/fullscreen-inhibit -t bool -s true
	xfconf-query -c xfce4-screensaver -n -p /saver/themes/list -t string -s "screensavers-xfce-personal-slideshow" -a
	xfconf-query -c xfce4-screensaver -n -p /screensavers/xfce-personal-slideshow/arguments -t string -s "--location='$wallpapersdir'"
	xfconf-query -c xfce4-screensaver -n -p /screensavers/xfce-personal-slideshow/location -t string -s "$wallpapersdir"
	xfconf-query -c xfce4-screensaver -n -p /lock/enabled -t bool -s true
	xfconf-query -c xfce4-screensaver -n -p /lock/saver-activation/delay -t int -s 10
	
	
}

function printMessage() {
	printf "\n\n\e[032;1m$1\e[m\n\n"; sleep 2;
}


printf "\n\n\e[032;1mInstalling Programs\e[m\n\n"; sleep 2;
sudo pamac install materia-gtk-theme papirus-icon-theme qt5ct deluge-gtk persepolis foliate evince code micro xclip copyq gcolor3 nodejs-lts-fermium npm shellcheck flameshot hardinfo neofetch bpytop catfish mlocate gnome-system-monitor gnome-disk-utility gnome-calculator firefox firefox-i18n-pt-br thunderbird thunderbird-i18n-pt-br obs-studio opus-tools youtube-dl pavucontrol pulseaudio-alsa steam-manjaro retroarch discord zsh ttf-meslo-nerd-font-powerlevel10k wget bat lsd git github-cli mpv ttf-dejavu ristretto gnupg openssh gvfs-mtp android-tools usbutils android-udev ffmpegthumbnailer tumbler thunar-archive-plugin thunar-volman file-roller unrar xdg-user-dirs timeshift lightdm-gtk-greeter-settings bootsplash-theme-manjaro ventoy inxi appimagelauncher xfce4-notifyd xfce4-power-manager polkit-gnome --no-confirm


function cpThemesWallpapers() {
	printMessage "$1"
	printf "\n\n\e[032;1mCopying themes, icons and wallpapers to /usr/share/ subdirectories to use globally\e[m\n\n"; sleep 2;
	
	sudo cp -r $HOME/.themes/* /usr/share/themes
	sudo cp -r $HOME/.icons/* /usr/share/icons
	[[ ! -d /usr/share/backgrounds ]] && sudo mkdir /usr/share/backgrounds
	sudo cp -r "$wallpapersdir"/* /usr/share/backgrounds || printf "\nWallpapers Directory not set or not found. Skipping\n"
}



printf "\n\n\e[032;1mInstalling VSCode extensions\e[m\n\n"; sleep 2;
code --install-extension alexcvzz.vscode-sqlite
code --install-extension dracula-theme.theme-dracula
code --install-extension jpoissonnier.vscode-styled-components
code --install-extension PKief.material-icon-theme


# Generate user dirs, set programs for some filetypes 
# and create .local/bin for my personal scripts from Github
xdg-user-dirs-update
xdg-mime default micro.desktop text/plain
xdg-mime default micro.desktop text/markdown
xdg-mime default org.gnome.Evince.desktop application/pdf

[[ ! -d $HOME/.local/bin ]] && mkdir $HOME/.local/bin;
cd $HOME/.local/bin; 
wget https://raw.githubusercontent.com/MetaKomora/ytdl-opus-shell/master/ytdl-opus;
wget https://raw.githubusercontent.com/MetaKomora/ytmpv/master/ytmpv;
chmod +x ytdl-opus ytmpv


printf "\n\n\e[032;1mCreating directory for Appimages\e[m\n\n"; sleep 2;
[[ ! -d $HOME/Programas ]] && mkdir $HOME/Programas;
# insomnia - https://github.com/Kong/insomnia/releases
# freetube - https://github.com/FreeTubeApp/FreeTube/releases
# marktext - https://github.com/marktext/marktext/releases


printf "\n\n\e[032;1mEnabling Pulseaudio echo-cancel module\e[m\n\n"; sleep 2;
printf "\nload-module module-echo-cancel source_name=noiseless\nset-default-source noiseless" | sudo tee -a /etc/pulse/default.pa
pulseaudio -k


printf "\n\n\e[032;1mConfiguring ZRAM\e[m\n\n"; sleep 3;
# Enable zram module
sudo modprobe zram
echo "zram" | sudo tee -a /etc/modules-load.d/zram.conf

# Configure the number of /dev/zram devices you want
echo "options zram num_devices=2" | sudo tee -a /etc/modprobe.d/zram.conf

# Create a udev rule. Change ATTR{disksize} to your needs
echo 'KERNEL=="zram0", ATTR{disksize}="2G" RUN="/usr/bin/mkswap /dev/zram0", TAG+="systemd"' | sudo tee -a /etc/udev/rules.d/99-zram.rules
echo 'KERNEL=="zram1", ATTR{disksize}="2G" RUN="/usr/bin/mkswap /dev/zram1", TAG+="systemd"' | sudo tee -a /etc/udev/rules.d/99-zram.rules

# Add /dev/zram to your fstab
echo "/dev/zram0 none swap defaults 0 0" | sudo tee -a /etc/fstab
echo "/dev/zram1 none swap defaults 0 0" | sudo tee -a /etc/fstab

# Alter swappiness priority to 5
echo "vm.swappiness = 5" | sudo tee -a /etc/sysctl.d/99-sysctl.conf




printf "\n\n\e[032;1mRemoving packages, orphan packages and clean pamac cache\e[m\n\n"; sleep 2;
sudo pamac remove -o manjaro-zsh-config nano vi xfce4-clipman-plugin --no-confirm;
sudo pamac clean --no-confirm;
sudo pamac clean -b --no-confirm;


# If there is a BTRFS snapshots subvolume dir in the variable, create a snapshot and update GRUB
[[ -d "$snapshotsdir" ]] && { 
sudo btrfs subvolume snapshot / "$snapshotsdir"/@/post_install__-__"$(date '+%d-%m-%Y_-_%R')"
sudo update-grub 
}


function zshTheming() {

	printMessage "$1"
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
	echo "zmodule romkatv/powerlevel10k" >> ~/.zimrc
	zimfw install
	echo 'export QT_QPA_PLATFORMTHEME="qt5ct"' >> ~/.zshenv
	
}

zshTheming "ZIMfw and powerlevel10k"


############################
##### Optional programs ####
############################
# alacarte fsearch-git recoll mtools exfat-utils lxsession-gtk3 dunst deadd-notification-center-bin clipit xfce4-clipman-plugin polybar calibre zeal nnn cmus noto-fonts noto-fonts-emoji ttf-fira-code otf-font-awesome gpick audacity mangohud lib32-mangohud ecm-tools lutris wine-staging kdeconnect bat lsd dmidecode baobab gnome-font-viewer dbeaver dupeguru grub-customizer indicator-stickynotes safeeyes screenkey soundconverter p7zip-full unrar selene-media-converter shellcheck yad xdman


# More information:

# https://wiki.archlinux.org/index.php/Improving_performance#Zram_or_zswap
# https://manjariando.wordpress.com/2019/06/20/bootsplash-fornecido-pelo-kernel/
# https://unix.stackexchange.com/questions/453585/shell-script-to-comment-and-uncomment-a-line-in-file
# https://linuxize.com/post/how-to-add-directory-to-path-in-linux/
# https://github.com/ytdl-org/youtube-dl#installation
# https://github.com/romkatv/powerlevel10k#oh-my-zsh
# https://diolinux.com.br/2019/09/remover-ruido-do-microfone-no-linux.html
# https://www.linuxuprising.com/2020/09/how-to-enable-echo-noise-cancellation.html
# https://wiki.manjaro.org/index.php/Set_all_Qt_app%27s_to_use_GTK%2B_font_%26_theme_settings
# https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script
