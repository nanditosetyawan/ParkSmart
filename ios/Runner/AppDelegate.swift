import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var audioPlayer: AVAudioPlayer?
  private var bgmPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let channel = FlutterMethodChannel(name: "com.example.smart_parking/audio", binaryMessenger: messenger)
      channel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else { return }
        switch call.method {
        case "playRawSound":
          let args = call.arguments as? [String: Any]
          let sound = (args?["sound"] as? String) ?? "start"
          self.playAudio(name: sound, loop: false, isBgm: false)
          result(true)
        case "playStartSound":
          self.playAudio(name: "start", loop: false, isBgm: false)
          result(true)
        case "startInGameSound":
          let args = call.arguments as? [String: Any]
          let isBonus = (args?["isBonus"] as? Bool) ?? false
          self.playAudio(name: isBonus ? "car_bonusmode" : "ingamecar", loop: true, isBgm: true)
          result(true)
        case "stopInGameSound":
          self.bgmPlayer?.stop()
          result(true)
        case "playGameOverSound":
          self.bgmPlayer?.stop()
          self.playAudio(name: "die", loop: false, isBgm: false)
          result(true)
        case "startClawsMusic":
          self.playAudio(name: "musiccrawls", loop: true, isBgm: true)
          result(true)
        case "stopClawsMusic":
          self.bgmPlayer?.stop()
          result(true)
        case "stopRawSound", "stopAllSounds":
          self.audioPlayer?.stop()
          self.bgmPlayer?.stop()
          result(true)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func playAudio(name: String, loop: Bool = false, isBgm: Bool = false) {
    let cleanName = name.replacingOccurrences(of: "-", with: "_")
    let key = FlutterDartProject.lookupKey(forAsset: "assets/audio/\(cleanName).mp3")
    guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
      return
    }
    let url = URL(fileURLWithPath: path)
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = loop ? -1 : 0
      player.prepareToPlay()
      player.play()
      if isBgm {
        self.bgmPlayer = player
      } else {
        self.audioPlayer = player
      }
    } catch {
      print("[AppDelegate] Audio error: \(error)")
    }
  }
}
