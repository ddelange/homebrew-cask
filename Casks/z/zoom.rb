cask "zoom" do
  arch arm: "arm64/"
  livecheck_folder = on_arch_conditional arm: "?archType=arm64"

  version "6.3.11.50104"
  sha256 arm:   "459541ab64d070fb3ef30c77630c0849581a3efc52f213fddefc5b24ca44853d",
         intel: "3b01d5a9065521095ab1e857e944c3d5f8356190c0b6f05949d3ead997b62530"

  url "https://cdn.zoom.us/prod/#{version}/#{arch}zoomusInstallerFull.pkg"
  name "Zoom"
  desc "Video communication and virtual meeting platform"
  homepage "https://www.zoom.us/"

  livecheck do
    url "https://www.zoom.us/client/latest/zoomusInstallerFull.pkg#{livecheck_folder}"
    strategy :header_match
  end

  auto_updates true
  conflicts_with cask: "zoom-for-it-admins"

  pkg "zoomusInstallerFull.pkg"

  postflight do
    # Description: Ensure console variant of postinstall is non-interactive.
    # This is because `open "$APP_PATH"&` is called from the postinstall
    # script of the package and we don't want any user intervention there.
    retries ||= 3
    ohai "The Zoom package postinstall script launches the Zoom app" if retries >= 3
    ohai "Attempting to close zoom.us.app to avoid unwanted user intervention" if retries >= 3
    return unless system_command "/usr/bin/pkill", args: ["-f", "/Applications/zoom.us.app"]
  rescue RuntimeError
    sleep 1
    retry unless (retries -= 1).zero?
    opoo "Unable to forcibly close zoom.us.app"
  end

  uninstall launchctl: [
              "us.zoom.updater",
              "us.zoom.updater.login.check",
              "us.zoom.ZoomDaemon",
            ],
            signal:    ["KILL", "us.zoom.xos"],
            pkgutil:   "us.zoom.pkg.videomeeting",
            delete:    [
              "/Applications/zoom.us.app",
              "/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
              "/Library/Logs/DiagnosticReports/zoom.us*",
              "/Library/PrivilegedHelperTools/us.zoom.ZoomDaemon",
            ]

  zap trash: [
    "~/.zoomus",
    "~/Desktop/Zoom",
    "~/Documents/Zoom",
    "~/Library/Application Scripts/*.ZoomClient3rd",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings",
    "~/Library/Application Support/CloudDocs/session/containers/iCloud.us.zoom.videomeetings.plist",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/us.zoom*.sfl*",
    "~/Library/Application Support/CrashReporter/zoom.us*",
    "~/Library/Application Support/zoom.us",
    "~/Library/Application Support/ZoomUpdater",
    "~/Library/Caches/us.zoom.xos",
    "~/Library/Cookies/us.zoom.xos.binarycookies",
    "~/Library/Group Containers/*.ZoomClient3rd",
    "~/Library/HTTPStorages/us.zoom.xos",
    "~/Library/HTTPStorages/us.zoom.xos.binarycookies",
    "~/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin",
    "~/Library/Logs/zoom.us",
    "~/Library/Logs/zoominstall.log",
    "~/Library/Logs/ZoomPhone",
    "~/Library/Preferences/us.zoom.*.plist",
    "~/Library/Preferences/ZoomChat.plist",
    "~/Library/Saved Application State/us.zoom.xos.savedState",
    "~/Library/WebKit/us.zoom.xos",
  ]
end
