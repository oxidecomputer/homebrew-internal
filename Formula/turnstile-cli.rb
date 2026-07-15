class TurnstileCli < Formula
  desc "Oxide Hiring CLI"
  homepage "https://github.com/oxidecomputer/turnstile"
  version "0.9.20"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.20/turnstile-cli-aarch64-apple-darwin.tar.xz"
      sha256 "46e1a4efbc65b5eb837266c1ebe0be134b232365b307f81cf5b713bb829cca38"
    end
    if Hardware::CPU.intel?
      url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.20/turnstile-cli-x86_64-apple-darwin.tar.xz"
      sha256 "15bbb2e94a8156fd2a877a724ca46d0ae7e5c9c05a954d89c931747de50f2cd4"
    end
  end
  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/oxidecomputer/turnstile/releases/download/v0.9.20/turnstile-cli-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "70d9908049e36172afc138736ebfa116ad78f2195ee4c38accf3e306326d392b"
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
    )

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
