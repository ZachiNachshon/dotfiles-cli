# typed: false
# frozen_string_literal: true

class DotfilesCli < Formula
  desc "CLI utility for managing a remote dotfiles repository"
  homepage "https://github.com/ZachiNachshon/dotfiles-cli"
  version "0.5.0"
  url "https://github.com/ZachiNachshon/dotfiles-cli/releases/download/v0.5.0/dotfiles-cli.tar.gz"
  sha256 "1c401bdc693ab52d37fb7b1e217aa9b9c9657bc294f4a6747d15b498cfc58790"
  license "MIT"

  depends_on "git"

  def install
    # Add extracted files to the Homebrew install directory
    libexec.install Dir["*"]
    libexec.install Dir[".git-deps"]
    # Add a relative symlink from Homebrew libexec to bin folder
    bin.install_symlink libexec/"dotfiles.sh" => "dotfiles"
  end
  
  test do
    system "#{bin}/dotfiles version"
  end
end
