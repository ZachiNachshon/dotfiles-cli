# typed: false
# frozen_string_literal: true

class DotfilesCli < Formula
  desc "CLI utility for managing a remote dotfiles repository"
  homepage "https://github.com/ZachiNachshon/dotfiles-cli"
  version "0.4.0"
  url "https://github.com/ZachiNachshon/dotfiles-cli/releases/download/v0.4.0/dotfiles-cli.tar.gz"
  sha256 "4379cc0efd8b03fa3ed13718c260a6913fb78af8671120f42569bfcc71ddeeb8"
  license "MIT"

  depends_on "git"

  def install
    # Add extracted files to the Homebrew install directory
    libexec.install Dir["*"]
    # Add a relative symlink from Homebrew libexec to bin folder
    bin.install_symlink libexec/"dotfiles.sh" => "dotfiles"
  end
  
  test do
    system "#{bin}/dotfiles version"
  end
end
