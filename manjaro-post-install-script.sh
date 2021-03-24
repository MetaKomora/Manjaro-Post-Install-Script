#!/bin/bash

function printMessage() {
	printf "\n\n\e[032;1m$1\e[m\n\n"; sleep 2;
}

# Low brightness level on i3 gaps
[[ "$XDG_SESSION_DESKTOP" == "i3" ]] && {
	xrandr --output LVDS-1 --brightness 0.50
	sudo pamac install otf-font-awesome --no-confirm

	git clone https://github.com/dracula/rofi
	mkdir $HOME/.config/rofi
	cp rofi/config.rasi ~/.config/rofi
	rm -rf rofi

}

# if the mirrors branch is not testing, change to it
[[ $(pacman-mirrors -G) != "testing" ]] && {

	sudo pacman-mirrors -c Brazil,United_States --api -B testing -P https -m rank
	sudo pamac update --force-refresh --no-confirm

}

# if Desktop Environment is XFCE, install Dockbarx plugin
[[ "$XDG_SESSION_DESKTOP" == "xfce" ]] && {

	printMessage "You are using XFCE. Installing xfce4-dockbarx-plugin and configuring environment"
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

	cd /usr/share/themes && sudo rm -rf Daloa Bright Default-hdpi Default-xhdpi Kokodi Moheli Retro Smoke "ZOMG-PONIES!"
	
}

function setVariables() {
	wallpapersdir=""
	snapshotsdir=""

	printf "\nPlease, insert your wallpapers directory:\n"
	read wallpapersdir

	printf "\nPlease, insert your snapshots directory:\n"
	read snapshotsdir
	
}

function installPrograms() {
	printMessage "$1"

	sudo pamac install materia-gtk-theme papirus-icon-theme qt5ct qt5-styleplugins aria2 foliate evince code micro xclip copyq gcolor3 flameshot hardinfo neofetch bpytop gnome-disk-utility gnome-calculator firefox-i18n-pt-br thunderbird-i18n-pt-br obs-studio youtube-dl pavucontrol pulseaudio-alsa steam-manjaro zsh git github-cli mpv ttf-dejavu ttf-meslo-nerd-font-powerlevel10k noto-fonts-cjk noto-fonts-emoji ristretto gnupg openssh gvfs-mtp android-tools android-udev ffmpegthumbnailer gnome-epub-thumbnailer tumbler thunar-archive-plugin thunar-volman file-roller unrar xdg-user-dirs lightdm-gtk-greeter-settings ventoy appimagelauncher xfce4-notifyd brightnessctl polkit-gnome --no-confirm
	
}

function cpThemesWallpapers() {
	printMessage "$1"
	
	sudo cp -r $HOME/.themes/* /usr/share/themes
	sudo cp -r $HOME/.icons/* /usr/share/icons
	[[ ! -d /usr/share/backgrounds ]] && sudo mkdir /usr/share/backgrounds
	if [[ -d "$wallpapersdir" ]]; then
		sudo cp -r "$wallpapersdir"/* /usr/share/backgrounds
	else
		printf "\n\e[031;1mWallpapers directory not set or not found. Skipping copy\e[m\n"
	fi
}

function vscodeExtensions() {
	printMessage "$1"
	
	code --install-extension alexcvzz.vscode-sqlite
	code --install-extension dracula-theme.theme-dracula
	code --install-extension jpoissonnier.vscode-styled-components
	code --install-extension PKief.material-icon-theme
}

function userEnvironmentSetup() {

	printMessage "$1"
	
	xdg-user-dirs-update
	xdg-mime default micro.desktop text/plain
	xdg-mime default micro.desktop text/markdown
	xdg-mime default org.gnome.Evince.desktop application/pdf
	
	[[ ! -d $HOME/.local/bin ]] && mkdir $HOME/.local/bin;
	cd $HOME/.local/bin;
	wget https://raw.githubusercontent.com/MetaKomora/ytdl-opus-shell/master/ytdl-opus;
	wget https://raw.githubusercontent.com/MetaKomora/ytmpv/master/ytmpv;
	chmod +x ytdl-opus ytmpv
	
	
	printMessage "Creating directory for appimages"
	[[ ! -d $HOME/Programas ]] && mkdir $HOME/Programas;
	# insomnia - https://github.com/Kong/insomnia/releases
	# freetube - https://github.com/FreeTubeApp/FreeTube/releases
	# marktext - https://github.com/marktext/marktext/releases
}

function enableEchoCancel() {
	printMessage "$1"

	printf "\nload-module module-echo-cancel source_name=noiseless\nset-default-source noiseless" | sudo tee -a /etc/pulse/default.pa
	pulseaudio -k
}

function enableZRAM() {

	printMessage "$1"
	
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
}

function cleanPackages() {
	printMessage "$1"
	
	sudo pamac remove -o manjaro-zsh-config nano vi --no-confirm;
	sudo pamac clean --no-confirm;
	sudo pamac clean -b --no-confirm;
}

function zshTheming() {

	printMessage "$1"	
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
	echo "zmodule romkatv/powerlevel10k" >> ~/.zimrc
	echo 'export QT_QPA_PLATFORMTHEME="qt5ct"' >> ~/.profile

	printMessage "Exec 'zimfw install' in a new shell to finish Powerlevel10k theme installation"
	
}

setVariables

installPrograms "Installing Programs"

cpThemesWallpapers "Copying themes, icons and wallpapers to /usr/share/ subdirectories to use globally"

vscodeExtensions "Installing VSCode extensions"

userEnvironmentSetup "Creating user directories, downloading personal scripts and setting default applications"

enableEchoCancel "Enabling Pulseaudio echo-cancel module"

enableZRAM "Enabling and configuring ZRAM"

cleanPackages "Removing packages, orphan packages and pamac cache"


# If there is a BTRFS snapshots subvolume dir in the variable, create a snapshot and update GRUB
[[ -d "$snapshotsdir" ]] && {
	sudo mkdir "$snapshotsdir"/{@,@home}
	sudo btrfs subvolume snapshot / "$snapshotsdir"/@/post_install__-__"$(date '+%d-%m-%Y_-_%R')"
	sudo update-grub
}


zshTheming "Installing ZIMfw and powerlevel10k theme"

printMessage "Please, reboot system to apply changes"

############################
##### Optional programs ####
############################
# alacarte fsearch-git catfish mlocate exfat-utils usbutils pamixer deadd-notification-center-bin xfce4-clipman-plugin polybar calibre man-db zeal nnn cmus opus-tools otf-font-awesome gpick audacity inxi mangohud lib32-mangohud ecm-tools lutris wine-staging discord kdeconnect udiskie dmidecode baobab gnome-font-viewer dbeaver dupeguru grub-customizer bootsplash-theme-manjaro screenkey soundconverter p7zip-full selene-media-converter timeshift xdman persepolis deluge-gtk ytfzf-git fzf ueberzug


# More information:

# https://wiki.archlinux.org/index.php/Improving_performance#Zram_or_zswap
# https://manjariando.wordpress.com/2019/06/20/bootsplash-fornecido-pelo-kernel/
# https://unix.stackexchange.com/questions/453585/shell-script-to-comment-and-uncomment-a-line-in-file
# https://linuxize.com/post/how-to-add-directory-to-path-in-linux/
# https://github.com/ytdl-org/youtube-dl#installation
# https://diolinux.com.br/2019/09/remover-ruido-do-microfone-no-linux.html
# https://www.linuxuprising.com/2020/09/how-to-enable-echo-noise-cancellation.html
# https://wiki.manjaro.org/index.php/Set_all_Qt_app%27s_to_use_GTK%2B_font_%26_theme_settings
# https://unix.stackexchange.com/questions/6345/how-can-i-get-distribution-name-and-version-number-in-a-simple-shell-script
# https://gist.github.com/jwebcat/5122366
