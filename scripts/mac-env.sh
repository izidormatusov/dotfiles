if [ "$IS_MAC" = "true" ]
then

echo "Setting up mac environment"

# Use Dark Mojave theme
defaults write -g AppleInterfaceStyle Dark

# Allow quiting of Finder
defaults write com.apple.finder QuitMenuItem -bool true

fi
