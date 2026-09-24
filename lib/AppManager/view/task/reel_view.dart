import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../view-model/task-vm/reel_vm.dart';
import '../../view-model/account-vm/user_vm.dart';

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

  // ===========================================================================
  // LANGUAGE HELPERS
  // ===========================================================================

  bool get isBurmese => widget.language == 'my';

  String tr(String english, String burmese) {
    return isBurmese ? burmese : english;
  }

  String taskTitle(int index) {
    return isBurmese
        ? 'ဗီဒီယိုလုပ်ငန်း #${index + 1}'
        : 'Task Video #${index + 1}';
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
          final reelsAsync = ref.read(reelsProvider);
          reelsAsync.whenData((reels) {
            if (reels.isNotEmpty) _loadVideo(reels, currentIndex);
          });
        } else {
          videoController?.play();
        }
      } else {
        videoController?.pause();
      }
    }
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

  Future<void> _loadVideo(List reels, int index) async {
    final oldController = videoController;
    videoController = null;
    if (oldController != null) {
      await oldController.pause();
      await oldController.dispose();
    }

    if (!mounted) return;

    setState(() {
      isLoading = true;
      isCompleted = false;
      currentIndex = index;
    });

    if (index >= reels.length) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(reels[index].videoUrl),
    );

    videoController = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);

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
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
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

  void onCompleteTask(String activeTier) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Get rewards specs based on current tier title
    double reward = 10.0;
    int maxTasks = 3;

    if (activeTier == 'SV2') { reward = 12.0; maxTasks = 3; }
    else if (activeTier == 'SV3') { reward = 20.0; maxTasks = 6; }
    else if (activeTier == 'GV1') { reward = 30.0; maxTasks = 12; }
    else if (activeTier == 'GV2') { reward = 40.0; maxTasks = 25; }
    else if (activeTier == 'GV3') { reward = 85.0; maxTasks = 30; }
    else if (activeTier == 'GO') { reward = 18.0; maxTasks = 5; }
    else if (activeTier == 'PLUS') { reward = 36.0; maxTasks = 5; }
    else if (activeTier == 'PRO') { reward = 54.0; maxTasks = 5; }
    else if (activeTier == 'MAX') { reward = 84.0; maxTasks = 5; }
    else if (activeTier == 'ULTRA') { reward = 102.0; maxTasks = 5; }
    else if (activeTier == 'INFINITY') { reward = 204.0; maxTasks = 5; }

    final error = await ref.read(userViewModelProvider).completeTaskReward(uid, reward, maxTasks);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      setState(() {
        isCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${tr('Task completed successfully! Received', 'လုပ်ငန်းအောင်မြင်စွာပြီးဆုံးပါပြီ။')} $reward THB',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

    final userProfile = userAsync.value;
    final activeTier = userProfile?.activeTier ?? 'Internship';

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: reelsAsync.when(
          data: (reels) {
            if (reels.isEmpty) {
              return Center(
                child: Text(
                  tr('No videos available.', 'ဗီဒီယိုများမရှိသေးပါ။'),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            // Fire first video load if initialized and controller is empty
            if (videoController == null && widget.currentTab) {
              Future.microtask(() => _loadVideo(reels, currentIndex));
            }

            return Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemCount: reels.length,
                  onPageChanged: (index) => _loadVideo(reels, index),
                  itemBuilder: (context, index) {
                    return _buildReel(index, reels[index], activeTier);
                  },
                ),
                if (currentIndex == 0)
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
        ),
      ),
    );
  }

  // ===========================================================================
  // SINGLE REEL WIDGET
  // ===========================================================================

  Widget _buildReel(int index, dynamic reel, String activeTier) {
    final controller = videoController;

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
                child: const Icon(Icons.task_alt, color: gold, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                '${index + 1}',
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
                tr(
                  'Watch this video to complete your daily task.',
                  'နေ့စဉ်လုပ်ငန်းပြီးမြောက်ရန် ဤဗီဒီယိုကို ကြည့်ပါ။',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isCompleted ? null : () => onCompleteTask(activeTier),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    disabledBackgroundColor: Colors.grey.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  child: Text(
                    isCompleted
                        ? tr('Completed', 'ပြီးမြောက်ပြီး')
                        : tr('Complete Task', 'လုပ်ငန်းပြီးမြောက်ရန်'),
                    style: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w800),
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
