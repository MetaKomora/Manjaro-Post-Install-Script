#!/bin/bash

function printMessage() {
	printf "\n\n\e[032;1m$1\e[m\n\n"; sleep 2;
}

function initialSystemSetup() {
	printMessage "$1"
	
	# if the mirrors branch is not unstable, change to it
	[[ $(pacman-mirrors -G) != "unstable" ]] && {
		sudo pacman-mirrors -c United_States,Canada -a -B unstable -P https -m rank
	}

	sudo pacman -Syyu pamac-gtk libpamac-flatpak-plugin polkit-gnome kitty micro pipewire-pulse brightnessctl --noconfirm --needed
	sudo pamac build ly --no-confirm
	sudo systemctl enable ly

	# Making some directories and exporting variables to easy setup later
	mkdir -p $HOME/.config/{zsh,zim,nvm} $HOME/.local/{bin,share}

	printf "export XDG_CONFIG_HOME=$HOME/.config\n" >> $HOME/.zshenv
	printf "export XDG_CACHE_HOME=$HOME/.cache\n" >> $HOME/.zshenv
	printf "export XDG_DATA_HOME=$HOME/.local/share\n" >> $HOME/.zshenv
	printf "export ZDOTDIR=$XDG_CONFIG_HOME/zsh\n" >> $HOME/.zshenv
	printf "export HISTFILE=$XDG_CONFIG_HOME/zsh/zhistory\n" >> $HOME/.zshenv
	printf "export ZIM_HOME=$XDG_CONFIG_HOME/zim\n" >> $HOME/.zshenv
	
}

function setVariables() {
	snapshotsdir=""
	#If nothing is passed, default to sway
	desktopEnvironment="sway"

	printf "\nPlease, insert your snapshots directory:\n"
	read snapshotsdir

	printf "\nPlease, insert the desired desktop environment: xfce, i3, sway or gnome (default sway)\n"
	read desktopEnvironment
}

function desktopEnvironmentSetup() {
	printMessage "$1"

	[[ $desktopEnvironment == "i3" ]] && {
		printMessage "You choose $desktopEnvironment. Installing environment"
		sudo pamac install i3-gaps rofi polybar picom nitrogen xorg-server xorg-xinit xorg-xinput lxappearance xclip xfce4-notifyd --no-confirm
		# Export $XDG_DATA_DIRS on i3 and XFCE to better integrate Flatpaks .desktop files
		printf "export XDG_DATA_DIRS=$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share\n" >> $HOME/.zshenv
	}
	
	[[ $desktopEnvironment == "xfce" ]] && {
		printMessage "You choose $desktopEnvironment. Installing and configuring environment"
		sudo pamac install xfce4 xfce4-whisker-menu xfce4-netload-plugin xfce4-systemload-plugin xfce4-pulseaudio-plugin --no-confirm
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
		xfconf-query -c xsettings -p /Net/ThemeName -s "Kripton";
		xfconf-query -c xfwm4 -p /general/theme -s "Kripton";
		
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
		
		# When a window raises itself, switch to window's workspace
		xfconf-query -c xfwm4 -n -p /general/activate_action -t string -s switch;
		
		# Settings Manager > Appearance > Fonts > Default Font
		xfconf-query -c xsettings -n -p /Gtk/FontName -t string -s "Noto Sans 10"
		
		# Settings Manager > Appearance > Fonts > Default Monospace Font
		xfconf-query -c xsettings -n -p /Gtk/MonospaceFontName -t string -s "Noto Sans Mono 10"
		
		# Settings Manager > Window Manager > Title Font
		xfconf-query -c xfwm4 -n -p /general/title_font -t string -s "Noto Sans Bold 9"
		
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
		cd $HOME
		printf "export XDG_DATA_DIRS=$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share\n" >> $HOME/.zshenv
	}
	
	[[ $desktopEnvironment == "gnome" ]] && {
		printMessage "You choose $desktopEnvironment. Installing environment"
		sudo pamac install gnome-shell gnome-control-center gnome-tweaks wl-clipboard --no-confirm
	}

	[[ $desktopEnvironment == "sway" ]] && {
		printMessage "You choose $desktopEnvironment. Installing environment"
		sudo pamac install sway waybar wofi grim mako xorg-xwayland wl-clipboard xdg-desktop-portal-gtk xdg-desktop-portal-wlr --no-confirm
		# Some Wayland programs reads the current desktop variable to identify sway properly
		printf "export XDG_CURRENT_DESKTOP=sway\n" >> $HOME/.zshenv
	}
}

function installPrograms() {
	printMessage "$1"

	sudo pamac install adapta-gtk-theme papirus-icon-theme aria2 docker neofetch bpytop gnome-disk-utility thunderbird-i18n-pt-br zsh github-cli youtube-dl pavucontrol ttf-meslo-nerd-font-powerlevel10k noto-fonts noto-fonts-cjk noto-fonts-emoji gvfs-mtp android-tools ffmpegthumbnailer ristretto thunar-volman thunar-archive-plugin file-roller xdg-user-dirs ventoy rsync stow man-db yad --no-confirm
	
	flatpak install firefox telegram flameshot libreoffice marktext evince freetube foliate calculator codium insomnia celluloid obs steam minetest -y
	flatpak install proton-GE
	
	# Grants Telegram access to $HOME directory to be able to send files in-app
	sudo flatpak override --filesystem=home org.telegram.desktop
	# Grants access to themes and icons inside $HOME directory to set the GTK theme
	sudo flatpak override --filesystem=~/.themes --filesystem=~/.icons --env=GTK_THEME=Kripton
	
	
}

function devEnvironmentSetup() {
	printMessage "$1"

	printf "\nInstalling NVM and latest node LTS\n"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
	printf '\nexport NVM_DIR="$HOME/.config/nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n' >> $HOME/.config/zsh/.zshrc
	source $HOME/.config/zsh/.zshrc
	nvm install --lts

	# Adding $USER to docker group to use docker rootless
	sudo usermod -a -G docker $USER	
}

function userEnvironmentSetup() {

	printMessage "$1"
	
	xdg-user-dirs-update
	xdg-mime default micro.desktop text/plain
	xdg-mime default micro.desktop text/markdown
	xdg-mime default org.gnome.Evince.desktop application/pdf

	# Prevents xdg-utils bug which it doesn't open files with Micro on Kitty
	ln -s /usr/bin/kitty $HOME/.local/bin/xterm
	
	cd $HOME/.local/bin
	curl https://raw.githubusercontent.com/MetaKomora/ytdl-opus-shell/master/ytdl-opus -o ytdl-opus;
	curl https://raw.githubusercontent.com/MetaKomora/ytmpv/master/ytmpv -o ytmpv;
	chmod +x ytdl-opus ytmpv
	cd $HOME
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

function zshTheming() {
	printMessage "$1"

	# Change shell to ZSH
	chsh -s /bin/zsh
	sudo chsh -s /bin/zsh
	source $HOME/.zshenv
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
	printf "zmodule romkatv/powerlevel10k" >> $HOME/.config/zsh/.zimrc
	printf 'export QT_QPA_PLATFORMTHEME="qt5ct"\n' >> $HOME/.zshenv

	printMessage "Exec 'zimfw install' in a new shell to finish Powerlevel10k theme installation"
	
}

# --------------------------------------------------------------------------------------------- #
# --------------------------------------------------------------------------------------------- #
# -------------------------------------Executing functions------------------------------------- #
# --------------------------------------------------------------------------------------------- #
# --------------------------------------------------------------------------------------------- #

initialSystemSetup "Change mirrors branch if needed, upgrade system and installs basic programs"

setVariables

desktopEnvironmentSetup "Installing Desktop Environment"

installPrograms "Installing Programs"

devEnvironmentSetup "Installing development tools"

userEnvironmentSetup "Creating user directories, downloading personal scripts and setting default applications"

enableZRAM "Enabling and configuring ZRAM"


# If there is a BTRFS snapshots subvolume dir in the variable, create a snapshot and update GRUB
[[ -d "$snapshotsdir" ]] && {
	sudo mkdir "$snapshotsdir"/{@,@home}
	sudo btrfs subvolume snapshot / "$snapshotsdir"/@/post_install__-__"$(date '+%d-%m-%Y_-_%R')"
	sudo btrfs subvolume snapshot /home "$snapshotsdir"/@home/post_install__-__"$(date '+%d-%m-%Y_-_%R')"
	sudo update-grub
}


zshTheming "Installing ZIMfw and powerlevel10k theme"

printMessage "Please, reboot system to apply changes"

############################
##### Optional programs ####
############################
# alacarte fsearch-git catfish mlocate exfat-utils usbutils pamixer deadd-notification-center-bin xfce4-clipman-plugin polybar calibre man-db zeal nnn cmus figlet opus-tools otf-font-awesome gpick audacity inxi mangohud lib32-mangohud ecm-tools lutris wine-staging discord kdeconnect udiskie dmidecode gdu baobab gnome-font-viewer dbeaver dupeguru grub-customizer bootsplash-theme-manjaro screenkey soundconverter p7zip-full selene-media-converter timeshift xdman persepolis deluge-gtk ytfzf-git fzf ueberzug


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
