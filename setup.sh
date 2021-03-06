#!/bin/bash

brewCask=("google-chrome" "1password" "iterm2" "slack" "dbeaver-community" "expressvpn" "visual-studio-code" "intellij-idea-ce" "steam" "vlc" "qbittorrent" "zoomus" "goland" "spectacle" "steermouse" "adoptopenjdk/openjdk/adoptopenjdk8" "docker" "sonos" "use-engine" "ngrok")
brew=("git" "bat" "zsh" "z" "vim" "wget" "curl" "htop" "pipenv" "gcc" "tree" "jq" "postgres" "coreutils" "r" "rsync" "tmux" "maven" "watch" "gdrive" "go-task/tap/go-task" "goreleaser" "pandoc" "rename" "hub" "sqlite")
npmGlobals=("now" "marko-cli" "http-server" "lasso-cli" "npm-check-updates" "typescript")

# Annoying macos stuff
echo -n "setting key repeat..."
defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

echo -n "cleaning toolbar..."
defaults write com.apple.dock persistent-apps -array

# Install Brew
echo -n "installing brew..."
command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }
brew tap homebrew/cask-drivers

for i in ${brewCask[@]}; do
  echo -n "installing $i..."
  brew cask list $i >/dev/null 2>&1 || brew cask install $i
done

for i in ${brew[@]}; do
  echo -n "installing $i..."
  brew list $i >/dev/null 2>&1 || brew install $i
done


# Oh My Zsh
echo -n "installing zsh / oh my zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" >/dev/null 2>&1
if grep -q "zshrc-ext" ~/.zshrc; then
  echo -n ""
else
  echo "source ~/.zshrc-ext" >> ~/.zshrc
  chsh -s /usr/local/bin/zsh
fi
echo "plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)" > ~/.zshrc-ext
echo ". `brew --prefix`/etc/profile.d/z.sh" >> ~/.zshrc-ext
echo "disable r functions" >> ~/.zshrc-ext

echo "setting up git"
echo "username:"
read gitUsername
echo "email:"
read gitEmail
git config --global user.email "$gitEmail"
git config --global user.name "$gitUsername"
git config --global pager.branch false

echo "configuring ssh"
ssh-keygen -t rsa -b 4096 -C "$gitEmail" -q -N "" -f ~/.ssh/id_rsa

# Node
echo "installing nvm..."
command -v nvm >/dev/null 2>&1
nvmExists=$?
if [ $nvmExists -ne 0 ]; then 
  NVM_DIR=""
  nvmLatest=$(curl https://github.com/nvm-sh/nvm/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*")
  nodeLatest=$(curl https://github.com/nodejs/node/releases/latest | egrep -so "[0-9]*\.[0-9]*\.[0-9]*")
  echo -n " nvm: $nvmLatest node: $nodeLatest"
  curl -s -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvmLatest}/install.sh" | bash
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
  nvm install $nodeLatest 
fi
for i in ${npmGlobals[@]}; do
  echo -n "installing $i..."
  npm install -g $i
done

# Go paths
echo "setting up golang"
echo 'export GOPATH="${HOME}/.go"' >> ~/.zshrc-ext
echo 'export GOROOT="$(brew --prefix golang)/libexec"' >> ~/.zshrc-ext
echo 'export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"' >> ~/.zshrc-ext
