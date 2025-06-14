import 'package:flutter/material.dart';
import 'package:marketplace_app_v0/core/utils/colorPalette.dart';
import 'package:marketplace_app_v0/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final onboardingData = [
      {
        "image": "assets/images/bagraaat.jpeg",
        "title": localizations.onboardingTitle,
        "description": localizations.onboardingDescription1,
      },
      {
        "image": "assets/images/dectct_bagra.jpg",
        "title": localizations.onboardingTitle,
        "description": localizations.onboardingDescription2,
      },
      {
        "image": "assets/images/thayaa.webp",
        "title": localizations.onboardingTitle,
        "description": localizations.onboardingDescription3,
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ColorPalette.primary),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: onboardingData.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 500,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(
                          onboardingData[index]["image"]!,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 100),
                      Text(
                        onboardingData[index]["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          onboardingData[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: ColorPalette.lightText,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: index == _currentPage
                          ? ColorPalette.activeDot
                          : ColorPalette.inactiveDot,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < onboardingData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                    );
                  } else {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: ColorPalette.secondary,
                  backgroundColor: ColorPalette.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  localizations.continueLabel,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
