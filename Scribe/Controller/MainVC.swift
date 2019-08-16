import UIKit
import Speech
import AVFoundation

class MainVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var displayText: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var playButton: CircleButton!
    //Variables
    var authorizationStatus:Bool = false
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        indicator.isHidden = true
        requestSpeechAuth()
    }
    
    @IBAction func onPlayPressed(_ sender: Any) {
        if authorizationStatus {
            indicator.isHidden = false
            indicator.startAnimating()
            playButton.isEnabled = false
            prepareAudioFile()
        }
    }
    
    private func requestSpeechAuth(){
        SFSpeechRecognizer.requestAuthorization { (authorizationStatus) in
            if authorizationStatus == SFSpeechRecognizerAuthorizationStatus.authorized{
                self.authorizationStatus = true
            }else{
                self.authorizationStatus = false
            }
        }
    }
    
    private func prepareAudioFile(){
        guard let path = Bundle.main.url(forResource: "sample", withExtension: "wav") else { return }
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.delegate = self
            audioPlayer.play()
            self.transcribeAudio(audioURL: path)
        }catch{
            debugPrint("MainVC.prepareAudioFile() \(error.localizedDescription)")
        }
    }
    
    private func transcribeAudio(audioURL:URL){
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let error = error{
                debugPrint("MainVC.transcribeAudio() \(error.localizedDescription)")
            }else{
                self.displayText.text = result?.bestTranscription.formattedString
            }
        })
    }
}

extension MainVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        indicator.stopAnimating()
        indicator.isHidden = true
        playButton.isEnabled = true
    }
}
