class PythinkerAi < Formula
  desc "Tiny async agent framework with chat channels, memory, MCP, and an OpenAI-compatible API"
  homepage "https://github.com/Pythoughts-labs/pythinker-home"
  url "https://files.pythonhosted.org/packages/66/b3/eed6a6c2f5bc955d203e4febcf20572f048d51170a40061c8cfac91acfd5/pythinker_ai-2.7.1.tar.gz"
  sha256 "123d282778c60870133ace40926b39c9222d44698273edb659fdab58fb98908a"
  license "MIT"

  depends_on "python@3.12"

  def install
    # Provision a plain venv and let pip resolve prebuilt wheels for
    # the Rust/C-extension dependency tree (cryptography, pydantic-core,
    # jiter, tiktoken, rpds-py, primp, Pillow, lxml, …). Using
    # `virtualenv_install_with_resources` would force `--no-binary :all:`
    # and require bootstrapping maturin from a Rust sdist inside PEP 517
    # build isolation, which is the failure mode this formula is escaping.
    python = Formula["python@3.12"].opt_libexec/"bin/python3"
    system python, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--no-warn-script-location",
      "--upgrade", "pythinker-ai"

    # dulwich's prebuilt macOS wheel ships a Mach-O accelerator
    # (_diff_tree.cpython-*-darwin.so) with insufficient header
    # padding for Homebrew's post-install pass to rewrite its
    # `install_name` to the absolute Cellar path. Rebuild dulwich
    # from sdist with `PURE=1`, which disables the C accelerator
    # entirely — there's no dylib left to relocate, and dulwich
    # transparently falls back to its pure-Python diff/pack/object
    # implementations (used here only by Pythinker's memory-commit
    # codepath, where perf is non-critical).
    ENV["PURE"] = "1"
    system libexec/"bin/pip", "install", "--force-reinstall",
      "--no-binary=dulwich", "--no-deps", "--no-warn-script-location",
      "dulwich"

    bin.install_symlink libexec/"bin/pythinker-ai"
  end

  test do
    system bin/"pythinker-ai", "--version"
  end
end
