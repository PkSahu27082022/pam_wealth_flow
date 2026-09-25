import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view-model/task-vm/reel_vm.dart';
import '../../view-model/account-vm/user_vm.dart';
import '../../view-model/investment-vm/investment_tier_vm.dart';
import '../../model/investment_tier_model.dart';
import '../../model/reel_model.dart';
import '../../service/snackbar_service.dart';

class DailyTasksPage extends ConsumerStatefulWidget {
  final String language;
  final bool currentTab;

  const DailyTasksPage({
    super.key,
    required this.language,
    required this.currentTab,
  });

  @override
  ConsumerState<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends ConsumerState<DailyTasksPage>
    with WidgetsBindingObserver {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);

  // ===========================================================================
  // PAGE CONTROLLER & STATE
  // ===========================================================================

  final PageController pageController = PageController();

  int currentIndex = 0;
  VideoPlayerController? videoController;

  bool isLoading = true;
  bool isCompleted = false;

  // New states for task progress
  double _videoProgress = 0.0;
  bool _hasWatchedFully = false;
  InvestmentTierModel? _currentTier;
  String? _currentVideoId;
  String? _currentVideoTitle;

  bool _watchAgainMode = false;

  // ===========================================================================
  // LANGUAGE HELPERS
  // ===========================================================================

  bool get isBurmese => widget.language == 'my';

  String tr(String english, String burmese) {
    return isBurmese ? burmese : english;
  }

  // ===========================================================================
  // LIFECYCLE & INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(DailyTasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentTab != widget.currentTab) {
      if (widget.currentTab) {
        if (videoController == null) {
          _refreshVideoList();
        } else {
          videoController?.play();
        }
      } else {
        videoController?.pause();
      }
    }
  }

  void _refreshVideoList() {
    final reelsAsync = ref.read(reelsProvider);
    reelsAsync.whenData((reels) {
      if (reels.isNotEmpty) {
        final user = ref.read(userProfileProvider).value;
        if (user != null && user.activeTier != 'None') {
          final watchedVideoIds = user.watchedVideoIds;
          final availableReels = reels.where((r) => !watchedVideoIds.contains(r.id)).toList();
          
          if (!_watchAgainMode && availableReels.isNotEmpty) {
             _loadVideo(availableReels, 0);
          } else if (_watchAgainMode) {
             _loadVideo(reels, 0);
          }
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final controller = videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (widget.currentTab) {
        controller.play();
      }
    }
  }

  @override
  void deactivate() {
    videoController?.pause();
    super.deactivate();
  }

  // ===========================================================================
  // LOAD VIDEO
  // ===========================================================================

  Future<void> _loadVideo(List<ReelModel> reels, int index) async {
    if (reels.isEmpty || index >= reels.length) return;
    
    final oldController = videoController;
    videoController = null;
    if (oldController != null) {
      oldController.removeListener(_videoListener);
      await oldController.pause();
      await oldController.dispose();
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
      isCompleted = false;
      _videoProgress = 0.0;
      _hasWatchedFully = false;
      currentIndex = index;
      _currentVideoId = reels[index].id;
      _currentVideoTitle = reels[index].title;
    });

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reels[index].videoUrl),
    );

    videoController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(false);
      controller.addListener(_videoListener);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        isLoading = false;
      });

      if (widget.currentTab) {
        await controller.play();
      }
    } catch (e) {
      debugPrint("Video Load Error: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _videoListener() {
    final controller = videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position.inMilliseconds;
    final duration = controller.value.duration.inMilliseconds;

    if (duration > 0) {
      final progress = (position / duration).clamp(0.0, 1.0);
      if ((progress - _videoProgress).abs() > 0.01) {
        setState(() {
          _videoProgress = progress;
        });
      }
    }

    // Detect video end
    if (!_hasWatchedFully && position >= duration && duration > 0) {
      _hasWatchedFully = true;
      if (!_watchAgainMode && _currentTier != null && _currentVideoId != null && _currentVideoTitle != null) {
        onCompleteTask(_currentTier!, _currentVideoId!, _currentVideoTitle!);
      }
    }
  }

  void _togglePlayPause() {
    final controller = videoController;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  // ===========================================================================
  // COMPLETE TASK & DISTRIBUTE REWARDS
  // ===========================================================================

  void onCompleteTask(InvestmentTierModel tier, String videoId, String videoTitle) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (isCompleted) return;

    final rewardStr = tier.payPerTask.replaceAll(RegExp(r'[^0-9]'), '');
    final reward = double.tryParse(rewardStr) ?? 0.0;

    final maxTasksStr = tier.dailyTask.replaceAll(RegExp(r'[^0-9]'), '');
    final maxTasks = int.tryParse(maxTasksStr) ?? 3;

    final error = await ref.read(userViewModelProvider).completeTaskReward(uid, reward, maxTasks, videoId, videoTitle);

    if (!mounted) return;

    if (error != null) {
      Alert.show(context, message: error, type: AlertType.error);
    } else {
      setState(() {
        isCompleted = true;
      });

      Alert.show(
        context, 
        message: '${tr('Task completed successfully! Received', 'လုပ်ငန်းအောင်မြင်စွာပြီးဆုံးပါပြီ။')} $reward THB',
        type: AlertType.success
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    videoController?.removeListener(_videoListener);
    videoController?.pause();
    videoController?.dispose();
    pageController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final reelsAsync = ref.watch(reelsProvider);
    final userAsync = ref.watch(userProfileProvider);
    final tiersAsync = ref.watch(investmentTiersProvider);

    final userProfile = userAsync.value;
    final activeTierTitle = userProfile?.activeTier ?? 'None';
    final completedToday = userProfile?.tasksCompletedToday ?? 0;
    final watchedVideoIds = userProfile?.watchedVideoIds ?? [];

    if (activeTierTitle == 'None') {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: gold, size: 80),
                const SizedBox(height: 24),
                Text(
                  tr('Plan Not Active', 'အစီအစဉ်မရှိသေးပါ'),
                  style: const TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('Please unlock an investment plan to start watching videos and earning rewards.', 'ဗီဒီယိုများကြည့်ရှုပြီး ဆုလာဘ်များရယူရန် ကျေးဇူးပြု၍ ရင်းနှီးမြှုပ်နှံမှု အစီအစဉ်တစ်ခုကို ဖွင့်ပါ။'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: tiersAsync.when(
          data: (tiers) {
            final tier = tiers.firstWhere(
              (t) => t.title == activeTierTitle,
              orElse: () => InvestmentTierModel(
                id: '',
                title: activeTierTitle,
                dailyTask: '0 Tasks',
                payPerTask: '0 THB',
                dailyRoi: '0 THB',
                investmentAmount: '0 THB',
                orderIndex: 0,
              ),
            );

            _currentTier = tier;

            final maxTasksStr = tier.dailyTask.replaceAll(RegExp(r'[^0-9]'), '');
            final maxTasks = int.tryParse(maxTasksStr) ?? 0;
            final remainingToday = maxTasks - completedToday;

            return reelsAsync.when(
              data: (reels) {
                if (reels.isEmpty) {
                  return Center(
                    child: Text(
                      tr('No videos available.', 'ဗီဒီယိုများမရှိသေးပါ။'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                // Normal Mode: Show unwatched videos within limit
                final unwatchedReels = reels.where((r) => !watchedVideoIds.contains(r.id)).toList();
                final availableReels = unwatchedReels.take(remainingToday > 0 ? remainingToday : 0).toList();

                // Logic for "Limit Reached" or "All unique watched" screen with "Watch Again"
                if (!_watchAgainMode) {
                  if (remainingToday <= 0 || (unwatchedReels.isEmpty && availableReels.isEmpty)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            remainingToday <= 0 ? Icons.check_circle_outline : Icons.history,
                            color: gold,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            remainingToday <= 0 
                              ? tr('Daily Limit Reached!', 'နေ့စဉ်ကန့်သတ်ချက် ပြည့်သွားပါပြီ။')
                              : tr('No New Tasks Available', 'လုပ်ဆောင်ရန် တာဝန်သစ်မရှိပါ'),
                            style: const TextStyle(color: gold, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              remainingToday <= 0 
                                ? tr('You have completed all your tasks for today. Come back tomorrow!', 'ယနေ့အတွက် တာဝန်အားလုံး ပြီးမြောက်ပါပြီ။ မနက်ဖြန်မှ ပြန်လာခဲ့ပါ။')
                                : tr('You have watched all unique videos in our library. Feel free to re-watch!', 'ရှိသမျှ ဗီဒီယိုများအားလုံး ကြည့်ရှုပြီးပါပြီ။ အဟောင်းများကို ပြန်လည်ကြည့်ရှုနိုင်ပါသည်။'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _watchAgainMode = true;
                                currentIndex = 0;
                              });
                              _loadVideo(reels, 0);
                            },
                            icon: const Icon(Icons.replay, color: Colors.black),
                            label: Text(tr('Watch Again', 'ပြန်လည်ကြည့်ရှုမည်')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }

                // If in watch again mode or has tasks
                final activeList = _watchAgainMode ? reels : availableReels;

                if (videoController == null && widget.currentTab) {
                  Future.microtask(() {
                    _loadVideo(activeList, 0);
                  });
                }

                return Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemCount: activeList.length,
                      onPageChanged: (index) => _loadVideo(activeList, index),
                      itemBuilder: (context, index) {
                        return _buildReel(index, activeList[index], tier, completedToday, maxTasks, watchedVideoIds);
                      },
                    ),
                    
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: gold.withOpacity(0.5)),
                            ),
                            child: Text(
                              _watchAgainMode 
                                ? tr('Review Mode (No Rewards)', 'ပြန်လည်ကြည့်ရှုခြင်း (ဆုကြေးမရှိ)')
                                : "${tr('Plan', 'အစီအစဉ်')}: ${tier.title}  |  ${tr('Progress', 'တိုးတက်မှု')}: $completedToday/$maxTasks",
                              style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (_watchAgainMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: GestureDetector(
                                onTap: () {
                                   setState(() {
                                     _watchAgainMode = false;
                                     videoController?.pause();
                                     videoController = null;
                                   });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    tr('Exit Review', 'ပြန်ထွက်မည်'),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (currentIndex == 0 && activeList.length > 1)
                      Positioned(
                        right: 15,
                        top: MediaQuery.of(context).size.height * 0.43,
                        child: Column(
                          children: [
                            const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 25),
                            Text(
                              tr('Swipe', 'ပွတ်ဆွဲပါ'),
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 25),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: gold)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: gold)),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  // ===========================================================================
  // SINGLE REEL WIDGET
  // ===========================================================================

  Widget _buildReel(int index, ReelModel reel, InvestmentTierModel tier, int completedToday, int maxTasks, List<String> watchedIds) {
    final controller = videoController;
    final showingCompletion = (isCompleted && index == currentIndex);
    final isAlreadyEarned = watchedIds.contains(reel.id);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (index == currentIndex && controller != null && controller.value.isInitialized)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          )
        else
          Container(
            color: const Color(0xFF10141A),
            child: const Center(child: CircularProgressIndicator(color: gold)),
          ),

        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),

        if (index == currentIndex && isLoading)
          const Center(child: CircularProgressIndicator(color: gold)),

        if (index == currentIndex && controller != null && controller.value.isInitialized)
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

        Positioned(
          right: 18,
          bottom: 115,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAlreadyEarned ? Icons.check_circle : Icons.task_alt,
                  color: isAlreadyEarned ? Colors.green : gold,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _watchAgainMode ? '#' : '${completedToday + index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        Positioned(
          left: 25,
          right: 25,
          bottom: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reel.title,
                style: const TextStyle(color: gold, fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _watchAgainMode 
                  ? tr('You are watching this in review mode.', 'ဤဗီဒီယိုကို ပြန်လည်ကြည့်ရှုနေခြင်းဖြစ်သည်။')
                  : tr('Watch this video fully to complete your daily task.', 'နေ့စဉ်လုပ်ငန်းပြီးမြောက်ရန် ဤဗီဒီယိုကို အပြည့်ကြည့်ပါ။'),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),

              // Animated Task Completion Button with Progress Loader
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: (showingCompletion || isAlreadyEarned) ? Colors.green : (_watchAgainMode ? Colors.blueGrey : gold),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: (showingCompletion || isAlreadyEarned) ? [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)] : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Stack(
                    children: [
                      // Progress Background Loader
                      if (!showingCompletion && !isAlreadyEarned && index == currentIndex)
                        Positioned.fill(
                          child: LinearProgressIndicator(
                            value: _videoProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.15)),
                          ),
                        ),

                      Center(
                        child: Text(
                          (showingCompletion || isAlreadyEarned)
                              ? tr('Completed', 'ပြီးမြောက်ပြီး')
                              : _watchAgainMode 
                                ? tr('Watching...', 'ကြည့်ရှုနေသည်...')
                                : tr('Complete Task', 'လုပ်ငန်းပြီးမြောက်ရန်'),
                          style: TextStyle(
                            color: (showingCompletion || isAlreadyEarned) ? Colors.white : Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
