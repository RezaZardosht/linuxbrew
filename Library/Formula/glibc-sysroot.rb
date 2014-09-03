require "formula"

class GlibcSysroot < Formula
  homepage "http://www.gnu.org/software/libc/download.html"
  url "http://ftpmirror.gnu.org/glibc/glibc-2.19.tar.bz2"
  sha1 "382f4438a7321dc29ea1a3da8e7852d2c2b3208c"

  option "without-sysroot", "Compile glibc for use with a non-sysroot GCC"

  # binutils 2.20 or later is required
  depends_on "binutils" => [:build, :optional]

  # Linux kernel headers 2.6.19 or later are required
  depends_on "linux-headers" => [:build, :optional]

  def install
    mkdir "build" do
      sysroot_prefix = build.with?("sysroot") ?
        "/Cellar/#{name}/#{version}" : prefix
      args = ["--disable-debug",
        "--disable-dependency-tracking",
        "--disable-silent-rules",
        "--prefix=#{sysroot_prefix}",
        "--without-selinux"] # Fix error: selinux/selinux.h: No such file or directory
      args << "--with-binutils=" +
        Formula["binutils"].prefix/"x86_64-unknown-linux-gnu/bin" if build.with? "binutils"
      args << "--with-headers=" +
        Formula["linux-headers"].include if build.with? "linux-headers"
      system "../configure", *args

      system "make" # Fix No rule to make target libdl.so.2 needed by sprof
      if build.with? "sysroot"
        system "make", "install", "DESTDIR=#{HOMEBREW_PREFIX}"
      else
        system "make", "install"
      end
    end
  end

  test do
    system "#{lib}/ld-linux-x86-64.so.2 2>&1 |grep Usage"
    system "#{lib}/ld-linux-x86-64.so.2 #{lib}/libc.so.6 --version"
    system "#{lib}/ld-linux-x86-64.so.2 #{lib}/libc.so.6 --library-path #{lib} #{bin}/locale --version"
  end
end
