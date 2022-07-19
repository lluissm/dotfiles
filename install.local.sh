current_date=$(date +"%d_%m_%Y_%H_%M")

# copy .zshrc while saving old one
zshrc_path=~/.zshrc
if [ -f "$zshrc_path" ]; then
    mv $zshrc_path "${zshrc_path}.backup_${current_date}"
fi
cp .zshrc $zshrc_path

# copy starship config
starship_config_path=~/.config/starship.toml
if [ -f "$starship_config_path" ]; then
    mv $starship_config_path "${starship_config_path}.backup_${current_date}"
else
    mkdir -p ~/.config/
fi
cp starship.toml $starship_config_path

source $zshrc_path
