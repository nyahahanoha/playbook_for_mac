#!/usr/bin/env bash

set -eu

is_arm() { test "$UNAME" == "arm64"; }

UNAME=`uname -m`

# 入っていなければ、コマンドライン・デベロッパツールをインストール
xcode-select -p 1>/dev/null || {
    echo "Installing Command line tools ..."
    xcode-select --install
    echo "Please exec ./bootstrap.sh again in $DOTPATH after installing command-line-tools and Rosetta2(M1 Mac only)."
    exit 1
}

if is_arm; then
    echo "Installing Rosetta2 ..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

if ! command -v brew > /dev/null 2>&1; then
    echo "Installing homebrew in /usr/local for Intel or Rosetta2 ..."
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
    if is_arm; then
        echo "Installing homebrew in /opt/homebrew for Arm ..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

echo "env is add /opt/homebrew/bin/brew"
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "install ansible git"
brew install ansible git
echo "start playbook"
ansible-playbook localhost.yml -K
