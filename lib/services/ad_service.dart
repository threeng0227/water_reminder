import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/constants/app_constants.dart';

class AdService {
  static final AdService _instance = AdService._();
  factory AdService() => _instance;
  AdService._();

  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool bannerLoaded = false;
  bool _rewardedLoaded = false;
  bool _interstitialLoaded = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadRewarded();
    _loadInterstitial();
  }

  BannerAd createBannerAd({required AdListener listener}) {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.adBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerLoaded = true;
          listener.onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          bannerLoaded = false;
          if (kDebugMode) print('Banner ad failed: $error');
        },
      ),
    );
    _bannerAd!.load();
    return _bannerAd!;
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AppConstants.adRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedLoaded = false;
          if (kDebugMode) print('Rewarded ad failed: $error');
        },
      ),
    );
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AppConstants.adInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoaded = false;
        },
      ),
    );
  }

  Future<bool> showRewarded({
    required void Function(AdWithoutView, RewardItem) onReward,
  }) async {
    if (!_rewardedLoaded || _rewardedAd == null) return false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedLoaded = false;
        _loadRewarded();
      },
    );
    await _rewardedAd!.show(onUserEarnedReward: onReward);
    return true;
  }

  Future<void> showInterstitial() async {
    if (!_interstitialLoaded || _interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialLoaded = false;
        _loadInterstitial();
      },
    );
    await _interstitialAd!.show();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    bannerLoaded = false;
  }
}

// Minimal AdListener interface for widgets to use
class AdListener {
  final void Function(Ad)? onAdLoaded;
  const AdListener({this.onAdLoaded});
}
