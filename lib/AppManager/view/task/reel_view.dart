import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DailyTasksPage extends StatefulWidget {
  final String language;
  final bool currentTab;

  const DailyTasksPage({
    super.key,
    required this.language,
    required this.currentTab,

  });

  @override
  State<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage>
    with WidgetsBindingObserver {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color gold = Color(0xFFDDB83A);
  static const Color background = Color(0xFF090D13);

  // ===========================================================================
  // TEST VIDEO URLS
  // ===========================================================================

  final List<String> videoUrls = [
    'https://assets.testfiles.dev/video/sample-3s.mp4',
    'https://cdn.truefilesize.com/mp4/sample-portrait.mp4',
    'https://cdn.truefilesize.com/mp4/sample-5mb.mp4',
  ];

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
    // Register App Lifecycle observer (background/foreground detection)
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && widget.currentTab) {
        _loadVideo(0);
      }
    });
  }

  @override
  void didUpdateWidget(DailyTasksPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentTab != widget.currentTab) {

      if (widget.currentTab) {
        if (videoController == null) {
          _loadVideo(currentIndex);
        } else {
          videoController?.play();
        }
      } else {
        videoController?.pause();
      }
    }
  }
  // Handle App Lifecycle Changes (App Backgrounded / Minimized)
// Handle App Lifecycle Changes (App Backgrounded / Minimized)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final controller = videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Pause video when app goes to background
      controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // ONLY resume if this is currently the active tab!
      if (widget.currentTab) {
        controller.play();
      }
    }
  }

  // Called when this route is removed or replaced via Navigation
  @override
  void deactivate() {
    videoController?.pause();
    super.deactivate();
  }

  // ===========================================================================
  // LOAD VIDEO
  // ===========================================================================

  Future<void> _loadVideo(int index) async {
    // 1. Pause and dispose the previous controller first
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

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrls[index]),
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

      await controller.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // ===========================================================================
  // PLAY / PAUSE CONTROLS
  // ===========================================================================

  void _onPageChanged(int index) {
    _loadVideo(index);
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

  void onCompleteTask() {
    final controller = videoController;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Task completed successfully',
            'လုပ်ငန်းပြီးမြောက်ပါပြီ',
          ),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    // Unregister App Lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Pause & Dispose Video Controller
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
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            // REELS PAGEVIEW
            PageView.builder(
              controller: pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: videoUrls.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildReel(index);
              },
            ),

            // TOP HEADER
            // Positioned(
            //   top: 15,
            //   left: 20,
            //   right: 20,
            //   child: Row(
            //     children: [
            //       GestureDetector(
            //         onTap: () async {
            //           // Explicitly pause before popping screen back
            //           await videoController?.pause();
            //           if (context.mounted) {
            //             Navigator.pop(context);
            //           }
            //         },
            //         child: Container(
            //           width: 42,
            //           height: 42,
            //           decoration: BoxDecoration(
            //             color: Colors.black.withOpacity(0.40),
            //             shape: BoxShape.circle,
            //           ),
            //           child: const Icon(
            //             Icons.arrow_back,
            //             color: Colors.white,
            //             size: 25,
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         child: Center(
            //           child: Text(
            //             tr(
            //               'Daily Tasks',
            //               'နေ့စဉ်လုပ်ငန်းများ',
            //             ),
            //             style: const TextStyle(
            //               color: gold,
            //               fontSize: 22,
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 12,
            //           vertical: 7,
            //         ),
            //         decoration: BoxDecoration(
            //           color: Colors.black.withOpacity(0.40),
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         child: Text(
            //           '${currentIndex + 1}/${videoUrls.length}',
            //           style: const TextStyle(
            //             color: Colors.white,
            //             fontSize: 13,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // SWIPE INDICATOR
            if (currentIndex == 0)
              Positioned(
                right: 15,
                top: MediaQuery.of(context).size.height * 0.43,
                child: Column(
                  children: [
                    const Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white70,
                      size: 25,
                    ),
                    Text(
                      tr('Swipe', 'ပွတ်ဆွဲပါ'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white70,
                      size: 25,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SINGLE REEL WIDGET
  // ===========================================================================

  Widget _buildReel(int index) {
    final controller = videoController;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (index == currentIndex &&
            controller != null &&
            controller.value.isInitialized)
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
            child: const Center(
              child: CircularProgressIndicator(
                color: gold,
              ),
            ),
          ),

        // GRADIENT OVERLAY
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

        // LOADING SPINNER
        if (index == currentIndex && isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: gold,
            ),
          ),

        // PLAY / PAUSE BUTTON
        if (index == currentIndex &&
            controller != null &&
            controller.value.isInitialized)
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
                  controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),

        // RIGHT SIDE TASK BADGE
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
                child: const Icon(
                  Icons.task_alt,
                  color: gold,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // BOTTOM CONTENT & ACTION BUTTON
        Positioned(
          left: 25,
          right: 25,
          bottom: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskTitle(index),
                style: const TextStyle(
                  color: gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr(
                  'Watch this video to complete your daily task.',
                  'နေ့စဉ်လုပ်ငန်းပြီးမြောက်ရန် ဤဗီဒီယိုကို ကြည့်ပါ။',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isCompleted ? null : onCompleteTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    disabledBackgroundColor: Colors.grey.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: Text(
                    isCompleted
                        ? tr('Completed', 'ပြီးမြောက်ပြီး')
                        : tr('Complete Task', 'လုပ်ငန်းပြီးမြောက်ရန်'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
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