class TurnstileCli < Formula
  desc "Oxide Hiring CLI"
  homepage "https://github.com/oxidecomputer/turnstile"
  version "0.9.9"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.9/turnstile-cli-aarch64-apple-darwin.tar.xz"
      sha256 "7ce86df6908f032ddbd65ae33b932513653bec581aee8a6496d4ea1d04f4f0f9"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.9/turnstile-cli-x86_64-apple-darwin.tar.xz"
      sha256 "17fbb815e4c7c17e695d6aa6c5aaaf81cf1074ec25b25c48b026add8383bf0df"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.9/turnstile-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "cd7c79fcfcec55d59aa930fb51bae64e3c2bddeb40093006927af157df865d77"
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
