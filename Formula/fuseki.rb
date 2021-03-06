class Fuseki < Formula
  desc "SPARQL server"
  homepage "https://jena.apache.org/documentation/fuseki2/"
  url "https://www.apache.org/dyn/closer.lua?path=/jena/binaries/apache-jena-fuseki-3.8.0.tar.gz"
  sha256 "0a541d03f396db66823f68774cc4b63627600bd94e97c07070837e9392498a49"

  bottle :unneeded

  def install
    prefix.install "bin"

    %w[fuseki-server fuseki].each do |exe|
      libexec.install exe
      (bin/exe).write_env_script(libexec/exe,
                                 :FUSEKI_BASE => var/"fuseki",
                                 :FUSEKI_HOME => libexec,
                                 :FUSEKI_LOGS => var/"log/fuseki",
                                 :FUSEKI_RUN => var/"run")
    end

    # Non-symlinked binaries and application files
    libexec.install "fuseki-server.jar",
                    "fuseki.war",
                    "webapp"
  end

  def post_install
    # Create a location for dataset and log files,
    # in case we're being used in LaunchAgent mode
    (var/"fuseki").mkpath
    (var/"log/fuseki").mkpath
  end

  plist_options :manual => "fuseki start"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/fuseki-server</string>
        </array>
      </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/fuseki-server", "--version"
  end
end
