var bmsLottieManager: BMSLottieAnimationManagerProtocol?

// initialise BMSLottieManager (may be in view DidLoad or init method)
bmsLottieManager = BMSLottieAnimationManager(
  animationURLString: "https://assets6.lottiefiles.com/packages/lf20_REOnx3.json", 
  lottieURLSource: .json // Optional parameter, bydefault it will treat the url as BMS URL
)

// Load lottie from url
bmsLottieManager?.loadLottieAnimation(
  completion: { 
    [weak self] lottieAnimationView in
    guard let lottieAnimationView = lottieAnimationView else { return }
    self?.view.addSubview(lottieAnimationView)
    lottieAnimationView.anchorSidesToSuperview()
  }
)

// start animation
bmsLottieManager?.startAnimation()


// start animation with completion
bmsLottieManager?.startAnimation(completionBlock)

// start animation with loop
bmsLottieManager?.startAnimation(inLoop: true)

//stop animation
bmsLottieManager?.stopAnimation()

//stop animation with completion
bmsLottieManager?.stopAnimation(completionBlock)
