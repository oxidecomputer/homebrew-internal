class TurnstileCli < Formula
  desc "Oxide Hiring CLI"
  homepage "https://github.com/oxidecomputer/turnstile"
  version "0.9.10"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.10/turnstile-cli-aarch64-apple-darwin.tar.xz"
      sha256 "a29c83e89d403daa9107d8d21033b9d00ae1e190bf018801048d67108c28a6b8"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.10/turnstile-cli-x86_64-apple-darwin.tar.xz"
      sha256 "305c1a91446a6f6a84b29fc3557c237faf38e543b168093215a98ce4902ee871"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.10/turnstile-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "1c4de4f95a95b8b89262faf1e6b57d315a3ee1f022209892488d50f819fa5a80"
  end
  license "MPL-2.0"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":              {},
    "x86_64-apple-darwin":               {},
    "x86_64-pc-windows-gnu":             {},
    "x86_64-unknown-linux-gnu":          {},
    "x86_64-unknown-linux-musl-dynamic": {},
    "x86_64-unknown-linux-musl-static":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "turnstile-cli" if OS.mac? && Hardware::CPU.arm?
    bin.install "turnstile-cli" if OS.mac? && Hardware::CPU.intel?
    bin.install "turnstile-cli" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!
    generate_completions_from_executable(
      bin/"turnstile",
      "completion",
      shell_parameter_format: :arg,
      shells:                 [:bash, :fish, :zsh],
    )

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
