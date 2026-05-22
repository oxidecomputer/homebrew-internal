class TurnstileCli < Formula
  desc "Oxide Hiring CLI"
  homepage "https://github.com/oxidecomputer/turnstile"
  version "0.9.12"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.12/turnstile-cli-aarch64-apple-darwin.tar.xz"
      sha256 "687e15b8deab7cc654d37ccb142e3b8dff6effc6f4ffaf30e443ca768339e0f6"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.12/turnstile-cli-x86_64-apple-darwin.tar.xz"
      sha256 "0f90b10bb58d0bd48959c884ecc56b8f4a178e145a5fc255abc91f3d8e63680a"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.12/turnstile-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "b852db0ce96a1a512ad99f79a3aac9cb69291642a46ea663cb673188026f8db8"
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
