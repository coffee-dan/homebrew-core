class BdwGc < Formula
  desc "Garbage collector for C and C++"
  homepage "https://www.hboehm.info/gc/"
  url "https://github.com/ivmai/bdwgc/releases/download/v8.2.2/gc-8.2.2.tar.gz"
  sha256 "f30107bcb062e0920a790ffffa56d9512348546859364c23a14be264b38836a0"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_ventura:  "0d49ed54da084483ddf742707bf206475f423dff3fa6e8d7b8c0c7d34a42bf70"
    sha256 cellar: :any,                 arm64_monterey: "7977dd204f6ea7d0b8438db5fecb8ceed6807788ba8e9b7e20d4a8886b6dce6a"
    sha256 cellar: :any,                 arm64_big_sur:  "162892760401052a1a6d6cb183bb6683c18905377489b9bf50151a80c816f967"
    sha256 cellar: :any,                 ventura:        "4f108e3270a93578914a3e3ef03ff57b2cb37637b068b43cc69efa81f54d6979"
    sha256 cellar: :any,                 monterey:       "4b2f9d80d7f7d5471c875c3254d933234f782f80b862ea69708a054ba33e5a52"
    sha256 cellar: :any,                 big_sur:        "a55727cc7d7a7dbc8f7e61aca70a94dc07dcaccbfbffc5f92fcdc77dec64eaa7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "e15d359d4a51607a8751eef4e7f213477f4d04fed463acbd0accc5d793e7178f"
  end

  head do
    url "https://github.com/ivmai/bdwgc.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool"  => :build
  end

  depends_on "libatomic_ops" => :build
  depends_on "pkg-config" => :build

  on_linux do
    depends_on "gcc" => :test
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-cplusplus",
                          "--enable-static",
                          "--enable-large-config"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <stdio.h>
      #include "gc.h"

      int main(void)
      {
        int i;

        GC_INIT();
        for (i = 0; i < 10000000; ++i)
        {
          int **p = (int **) GC_MALLOC(sizeof(int *));
          int *q = (int *) GC_MALLOC_ATOMIC(sizeof(int));
          assert(*p == 0);
          *p = (int *) GC_REALLOC(q, 2 * sizeof(int));
        }
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lgc", "-o", "test"
    system "./test"
  end
end
