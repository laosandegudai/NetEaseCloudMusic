//
//  PlaySongViewController.swift
//  NetEaseCloudMusic
//
//  Created by Ampire_Dan on 2016/7/14.
//  Copyright © 2016年 Ampire_Dan. All rights reserved.
//

import UIKit


class PlaySongViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var needleImageView: UIImageView!
    @IBOutlet weak var blurBackgroundImageView: UIImageView!
    @IBOutlet weak var swipableDiscView: UIScrollView!
    @IBOutlet weak var loveImageView: UIImageView!
    @IBOutlet weak var downloadImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var timePointLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentLocationSlider: UISlider!
    @IBOutlet weak var playModeImageView: UIImageView!
    @IBOutlet weak var lastSongImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    @IBOutlet weak var totalSettingImageView: UIImageView!
    @IBOutlet weak var dotCurrentProcess: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    
    // MARK: - Tap Action
    
    func tapPlayImage() -> Void {
        isPlaying = !isPlaying
        isPlaying ? playSongService.startPlay() : playSongService.pausePlay()
        
        changePlayImage()
        changeNeedlePosition(true)
    }
    
    func tapPrevSongImage() {
        playSongService.playPrev()
        
        currentSongIndex = playSongService.currentPlaySong
        currentSongIndexChange()
        
        changeTitleText()
        changeBackgroundBlurImage()
        changeProgressAndText(0, duration: 0)
    }
    
    func tapNextSongImage() {
        playSongService.playNext()
        
        currentSongIndex = playSongService.currentPlaySong
        currentSongIndexChange()
        
        changeTitleText()
        changeBackgroundBlurImage()
        changeProgressAndText(0, duration: 0)
    }
    
    func tapLoveImage() {
        isLike = !isLike
        changeLikeImage(true)
    }
    
    func tapPlayModeImage() {
        playMode.next()
        playModeChange()
        
        changePlayModeImage()
    }
    
    func tapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tapShareButton() {
    }
    
    // MARK: - Property
    
    var data: CertainSongSheet?
    var currentSongIndex = 0
    var picUrl = ""
    var blurPicUrl = ""
    var songname = ""
    var singers = ""
    
    var isPlaying = false
    var isLike = false
    var playMode = PlayMode.Order
    
    let playSongService = PlaySongService.sharedInstance
        
    private lazy var marqueeTitleLabel: MarqueeLabel = {
        let label =  MarqueeLabel.init(frame: CGRectMake(0, 0, 200, 24), duration: 10, fadeLength:10)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.type = .Continuous
        label.font = UIFont.systemFontOfSize(15)
        return label
    }()
    
    private lazy var singerNameLabel: UILabel = {
        let label = UILabel.init(frame: CGRectMake(0, 0, 200, 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(11)
        label.center = CGPointMake(100, 33)
        label.textAlignment = .Center
        return label
    }()
    
    // MARK: Override method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataInit()
        viewsInit()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.sharedApplication().statusBarStyle = .Default
        setAnchorPoint(CGPointMake(0.5, 0.5), forView: self.needleImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var backButtonCenter = backButton.center
        backButtonCenter.y = 44
        backButton.center = backButtonCenter
        
        var shareButtonCenter = shareButton.center
        shareButtonCenter.y = 44
        shareButton.center = shareButtonCenter
    }
    
    // MARK: Supporting For Data
    
    // dataInit called only once
    func dataInit() {
        playSongService.delegate = self
        playSongService.playLists = data
        playModeChange()
        currentSongIndexChange()
        if isPlaying {
            playSongService.playCertainSong(currentSongIndex)
        }
    }
    
    func currentSongIndexChange()  {
        if let da = data {
            self.picUrl = da.tracks[currentSongIndex]["album"]!["picUrl"] as! String
            self.blurPicUrl = da.tracks[currentSongIndex]["album"]!["blurPicUrl"] as! String
            self.songname = da.tracks[currentSongIndex]["name"] as! String
            self.singers = da.tracks[currentSongIndex]["artists"]![0]["name"] as! String
        }
    }
    
    func playModeChange() {
        playSongService.playMode = playMode
    }
    
    // MARK: Supporting For View
    
    // viewsInit called only once
    func viewsInit() {
        // blurBackgroundImageView
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = blurBackgroundImageView.bounds
        blurBackgroundImageView.addSubview(visualEffectView)
        
        // swipableDiscView
        swipableDiscView.delegate = self
        
        // loveImageView
        let tapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapLoveImage))
        tapGest.numberOfTapsRequired = 1
        loveImageView.addGestureRecognizer(tapGest)
        
        // currentLocationSlider
        currentLocationSlider.setThumbImage(UIImage.init(named: "cm2_fm_playbar_btn"), forState: .Normal)
        currentLocationSlider.minimumTrackTintColor = FixedValue.mainRedColor
        
        // playModeImageView
        let ptapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapPlayModeImage))
        playModeImageView.addGestureRecognizer(ptapGest)
        
        // lastSongImageView
        let ltapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapPrevSongImage))
        lastSongImageView.addGestureRecognizer(ltapGest)
        
        // playImageView
        let PIVtapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapPlayImage))
        playImageView.addGestureRecognizer(PIVtapGest)
        
        // nextImageView
        let ntapGest = UITapGestureRecognizer.init(target: self, action: #selector(tapNextSongImage))
        nextImageView.addGestureRecognizer(ntapGest)
        
        // titleView
        titleView.addSubview(self.marqueeTitleLabel)
        titleView.addSubview(self.singerNameLabel)
        
        backButton.addTarget(self, action: #selector(tapBackButton), forControlEvents: .TouchUpInside)
        shareButton.addTarget(self, action: #selector(tapShareButton), forControlEvents: .TouchUpInside)
        
        
        
        changeTitleText()
        changeBackgroundBlurImage()
        changePlayModeImage()
        changePlayImage()
//        changeNeedlePosition(false)
        changeProgressAndText(0, duration: 0)
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    
    func needleUp(animate: Bool) {
        let point = self.view.convertPoint(CGPointMake(self.view.bounds.size.width/2, 64), toView: self.needleImageView)
        let anchorPoint = CGPointMake(point.x/self.needleImageView.bounds.size.width, point.y/self.needleImageView.bounds.size.height)
        self.setAnchorPoint(anchorPoint, forView: self.needleImageView)
        
        let angle = CGFloat(0)
        if animate {
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                self.needleImageView.transform = CGAffineTransformMakeRotation(angle)
                }, completion: nil)
        } else {
            self.needleImageView.transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    func needleDown(animate: Bool) {
        let point = self.view.convertPoint(CGPointMake(self.view.bounds.size.width/2, 64), toView: self.needleImageView)
        let anchorPoint = CGPointMake(point.x/self.needleImageView.bounds.size.width, point.y/self.needleImageView.bounds.size.height)
        self.setAnchorPoint(anchorPoint, forView: self.needleImageView)
        
        let angle = -CGFloat(M_PI/360 * 50)
        if animate {
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: {
                self.needleImageView.transform = CGAffineTransformMakeRotation(angle)
                }, completion: nil)
        } else {
            self.needleImageView.transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    func changeTitleText() {
        marqueeTitleLabel.text = songname
        singerNameLabel.text = singers
    }
    
    func changeBackgroundBlurImage() {
        blurBackgroundImageView?.sd_setImageWithURL(NSURL.init(string: blurPicUrl))
    }
    
    func changePlayModeImage() {
        switch playMode {
        case PlayMode.Shuffle:
            playModeImageView.image = UIImage.init(named: "cm2_icn_shuffle")
            playModeImageView.highlightedImage = UIImage.init(named: "cm2_icn_shuffle_prs")
            break
        case PlayMode.Cycle:
            playModeImageView.image = UIImage.init(named: "cm2_icn_loop")
            playModeImageView.highlightedImage = UIImage.init(named: "cm2_icn_loop_prs")
            break
        case PlayMode.Repeat:
            playModeImageView.image = UIImage.init(named: "cm2_icn_one")
            playModeImageView.highlightedImage = UIImage.init(named: "cm2_icn_one_prs")
            break
        case PlayMode.Order:
            playModeImageView.image = UIImage.init(named: "cm2_icn_order")
            playModeImageView.highlightedImage = UIImage.init(named: "cm2_icn_order_prs")
            break
        }
    }
    
    func changePlayImage() {
        if isPlaying {
            playImageView.image = UIImage.init(named: "cm2_fm_btn_pause")
        } else {
            playImageView.image = UIImage.init(named: "cm2_fm_btn_play")
        }
    }
    
    func changeNeedlePosition(animate: Bool) {
        if isPlaying {
            needleDown(animate)
        } else {
            needleUp(animate)
        }
    }
    
    func changeLikeImage(animate: Bool) {
        if isLike {
            loveImageView.image = UIImage.init(named: "cm2_play_icn_loved")
            if animate {
                UIView.animateWithDuration(0.1, animations: {
                    self.loveImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2)
                    }, completion: { (finished) in
                        UIView.animateWithDuration(0.1, animations: {
                            self.loveImageView.transform = CGAffineTransformScale(self.loveImageView.transform, 0.8, 0.8)
                            }, completion: { (finished) in
                                UIView.animateWithDuration(0.1, animations: {
                                    self.loveImageView.transform = CGAffineTransformScale(self.loveImageView.transform, 1, 1)
                                    }, completion: { (finished) in
                                        self.loveImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                                })
                        })
                })
            }
        } else {
            loveImageView.image = UIImage.init(named: "cm2_play_icn_love")
        }
    }
    
    func changeProgressAndText(current: Float64, duration: Float64) {
        self.totalTimeLabel.text = getFormatTime(duration)
        self.timePointLabel.text = getFormatTime(current)
        if duration != 0 && !duration.isNaN && !current.isNaN {
            self.currentLocationSlider.setValue(Float(current / duration) , animated: true)
        } else {
            self.currentLocationSlider.setValue(0 , animated: true)
        }
    }
    
    // MARK: Data Util
    
    func getFormatTime(time: Float64) -> String {
        if time.isNaN {
            return "00:00"
        }
        let minuteValue = Int(time / 60)
        let secondValue = Int(time) - minuteValue * 60
        
        var secondStr = "\(secondValue)"
        if secondValue < 10 {
            secondStr = "0" + secondStr
        }
        
        var minStr = "\(minuteValue)"
        if minuteValue < 0 {
            minStr = "00"
        } else if minuteValue < 9 {
            minStr = "0" + minStr
        }
        
        return minStr + ":" + secondStr
    }
}

extension PlaySongViewController: UIScrollViewDelegate {
}

extension PlaySongViewController: PlaySongServiceDelegate {
    func updateProgress(currentTime: Float64, durationTime: Float64) {
        changeProgressAndText(currentTime, duration: durationTime)
    }
}
