class TurnstileCli < Formula
  desc "Oxide Hiring CLI"
  homepage "https://github.com/oxidecomputer/turnstile"
  version "0.9.7"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.7/turnstile-cli-aarch64-apple-darwin.tar.xz"
      sha256 "3dc25e6a5dbc92ba62b65836047c97ae8bc057cc551e643d4b32aa0155aadab2"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.7/turnstile-cli-x86_64-apple-darwin.tar.xz"
      sha256 "27679173715fde83ef0be5c8e5811d70d54dc767bc4d3da5f7649ba03a9963b6"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.7/turnstile-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "f1e274e2e0aee008bab8436da6a275861ba1d9cc9a431386d9b52071038dc5f1"
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
