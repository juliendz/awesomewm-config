My configuration and theme for the Awesome WM

#Setup
Clone into ~/.config/awesome

#Install vicious widget library
sudo pacman -S vicious

#Install latest version of bashets.lua
https://gitorious.org/bashets/bashets

#Install xdg_menu
sudo pacman -S archlinux-xdg-menu

#Link bashets.conf to /usr/lib/tmpfiles.d
sudo ln -s bashets.conf /usr/lib/tmpfiles.d/bashets.conf
