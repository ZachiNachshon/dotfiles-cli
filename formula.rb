# typed: false
# frozen_string_literal: true

class DotfilesCli < Formula
  desc "CLI utility for managing a remote dotfiles repository"
  homepage "https://github.com/ZachiNachshon/dotfiles-cli"
  version "0.3.0"
  url "https://github.com/ZachiNachshon/dotfiles-cli/releases/download/v0.3.0/dotfiles-cli.tar.gz"
  sha256 "a11869e49d4667bb6ab4a58c4bdd98d7a957321210b7513225548e03d454be7d"
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
