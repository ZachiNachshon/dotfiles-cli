# typed: false
# frozen_string_literal: true

# Debug local formula instructions:
# 1. Edit the formulat file:
#      /usr/local/Homebrew/Library/Taps/zachinachshon/homebrew-tap/Formula/dotfiles-cli.rb
# 2. Reinstall the formula:
#      brew reinstall --build-from-source dotfiles-cli
class DotfilesCli < Formula
  desc "CLI utility for managing a remote dotfiles repository"
  homepage "https://github.com/ZachiNachshon/dotfiles-cli"
  version "0.6.0"
  url "https://github.com/ZachiNachshon/dotfiles-cli/releases/download/v0.6.0/dotfiles-cli.tar.gz"
  sha256 "f4b5839ba9b048219951b2a3d97549bfb1cc238fe7a4905f6d40854a13403e5b"
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
