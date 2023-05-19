#!/usr/bin/ bash

set -eu

is_arm() { test "$UNAME" == "arm64"; }

UNAME=`uname -m`

# 入っていなければ、コマンドライン・デベロッパツールをインストール
xcode-select -p 1>/dev/null || {
    echo "Installing Command line tools ..."
    xcode-select --install
    # その場合、M1 Mac では Rosetta2 もインストールされていないと思われるので、こちらもインストール
    if is_arm; then
        # ソフトウェアアップデートで Rosetta2 をインストール。面倒なのでライセンス確認クリックをスキップ
        echo "Installing Rosetta2 ..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    fi
    echo "Please exec ./bootstrap.sh again in $DOTPATH after installing command-line-tools and Rosetta2(M1 Mac only)."
    exit 1
}

# install homebrew
if ! command -v brew > /dev/null 2>&1; then
    # Install homebrew in Intel Mac or M1 Mac on Rosetta2
    echo "Installing homebrew in /usr/local for Intel or Rosetta2 ..."
    arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
    # M1 Mac では /opt/homebrew にネイティブ版をインストール
    if is_arm; then
        echo "Installing homebrew in /opt/homebrew for Arm ..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

brew install ansible git

ansible-playbook localhost.yml
