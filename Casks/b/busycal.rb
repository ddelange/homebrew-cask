cask "busycal" do
  version "2025.2.1,2025-04-30-12-16"
  sha256 "8b603dda63146ee355c605e4dce95d8525da12d935964ba60d8eb67dddf0203f"

  url "https://downloads.busymac.com/bcl-#{version.csv.first}-#{version.csv.second}.zip"
  name "BusyCal"
  desc "Calendar software focusing on flexibility and reliability"
  homepage "https://busymac.com/busycal/index.html"

  livecheck do
    url "https://www.busymac.com/download/BusyCal.zip"
    regex(%r{/bcl[._-]v?(\d+(?:\.\d+)+)[._-](\d+(?:-\d+)+)\.zip}i)
    strategy :header_match do |headers, regex|
      headers["location"]&.scan(regex)&.map { |match| "#{match[0]},#{match[1]}" }
    end
  end

  auto_updates true
  depends_on macos: ">= :catalina"

  pkg "BusyCal Installer.pkg"

  uninstall launchctl: "N4RA379GBW.com.busymac.busycal3.alarm",
            quit:      "N4RA379GBW.com.busymac.busycal3.alarm",
            signal:    ["TERM", "com.busymac.busycal3"],
            pkgutil:   "com.busymac.busycal3.pkg",
            delete:    "/Applications/BusyCal.app"

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.busymac.busycal#{version.major}.sfl*",
    "~/Library/Containers/com.busymac.busycal#{version.minor}",
    "~/Library/Containers/N4RA379GBW.com.busymac.busycal#{version.minor}.alarm",
    "~/Library/Group Containers/com.busymac.busycal#{version.minor}",
    "~/Library/Group Containers/N4RA379GBW.com.busymac.busycal#{version.minor}",
  ]
end
