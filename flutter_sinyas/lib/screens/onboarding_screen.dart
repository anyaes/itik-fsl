import 'dart:math' as math;

import 'package:flutter/material.dart';
import '/widgets/choice_card.dart';
import '/widgets/button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int selectedIndex = 0;
  int onboardingStep = 0;
  int? selectedKnowledgeIndex;

  static const learnerTypes = [
    'A guardian or parent',
    'A learner',
    'Just wanna learn',
  ];

  static const knowledgeLevels = [
    'I\'m completely new!',
    'I know a little bit of FSL',
  ];
  double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.sizeOf(context).width;
  double scaleFactor = screenWidth / 375.0; // 375 is standard mobile design width
  return (baseFontSize * scaleFactor).clamp(baseFontSize * 0.8, baseFontSize * 1.4);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          const mascotHeightFraction = 0.28;
          final compact = constraints.maxHeight < 750;
          final panelTop = constraints.maxHeight * (compact ? 0.16 : 0.25);
          final mascotSize = math.min(
            constraints.maxWidth * 0.5,
            constraints.maxHeight * mascotHeightFraction,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF3FA2C9), Colors.white],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: panelTop),
                    Expanded(
                      child: ClipPath(
                        clipper: _CurvedPanelClipper(),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 450),
                                    switchInCurve: Curves.easeOutBack,
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (child, animation) {
                                      final scaleAnimation = Tween<double>(
                                        begin: 0.92,
                                        end: 1,
                                      ).animate(animation);

                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: scaleAnimation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: switch (onboardingStep) {
                                      0 => Column(
                                        key: const ValueKey(0),
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 24),
                                          const Text(
                                            'I am...',
                                            style: TextStyle(
                                              color: Color(0xFF002247),
                                              fontSize: 80,
                                              fontWeight: FontWeight.bold,
                                              height: 0.8,
                                            ),
                                          ),
                                          const Text(
                                            'Choose which best describes you as a learner. There are no right or wrong answers.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF002247),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ChoiceCard(
                                            title: learnerTypes[0],
                                            subtitle:
                                                'I\'m learning FSL to support someone in my household.',
                                            isSelected: selectedIndex == 0,
                                            onTap: () => setState(
                                              () => selectedIndex = 0,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ChoiceCard(
                                            title: learnerTypes[1],
                                            subtitle:
                                                'I want to learn FSL to communicate as a need.',
                                            isSelected: selectedIndex == 1,
                                            onTap: () => setState(
                                              () => selectedIndex = 1,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ChoiceCard(
                                            title: learnerTypes[2],
                                            subtitle:
                                                'I just want to learn FSL on my own.',
                                            isSelected: selectedIndex == 2,
                                            onTap: () => setState(
                                              () => selectedIndex = 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      1 => Center( // knowledge levels section
                                        key: const ValueKey(1),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const SizedBox(height: 24),
                                            Text(
                                              'How much do you know?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF002247),
                                                fontSize: compact ? 56 : 80,
                                                height: 0.8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Do you know any FSL or are you completely new?',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF002247),
                                                fontSize: 24,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            
                                              ChoiceCard(
                                              title: knowledgeLevels[0], 
                                              subtitle: 'Start with the basics and learn step by step.', 
                                              isSelected: selectedKnowledgeIndex == 0, 
                                              onTap: () => setState(
                                                () => selectedKnowledgeIndex = 0)
                                            ),
                                            
                                            const SizedBox(height: 12),
                                            
                                              ChoiceCard(
                                              title: knowledgeLevels[1], 
                                              subtitle: 'Answer a few questions to find your starting point.', 
                                              isSelected: selectedKnowledgeIndex == 1, 
                                              onTap: () => setState(
                                                () => selectedKnowledgeIndex = 1)
                                            )
                                            
                                          ], // End of children array
                                        ),
                                      ),
                                      2 => Center(
                                        /* 
                                        switch then if its this choice, go heree, if anoither choice, go another
                                        */
                                         // take placement test or  not
                                        key: const ValueKey(2),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const SizedBox(height: 24),
                                            Text(
                                              'That\'s cool!',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color(0xFF002247),
                                                fontSize: 80,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if(selectedKnowledgeIndex == null)
                                              const Text('Choose a knowledge level')
                                            else if (selectedKnowledgeIndex == 0)
                                              const Text('Show content for beginners')
                                            else
                                              const Text('Aaaaaaaaaaaa'),                                           
                                          ],
                                        ),
                                      ),
                                      _ => const SizedBox.shrink(),
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  24,
                                  compact ? 12 : 24,
                                  24,
                                  compact ? 12 : 25,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Button(
                                    title: 'CONTINUE',
                                    onTap: () => setState(() {
                                      final knowledgeLevel = selectedKnowledgeIndex == null ? 'not selected' : knowledgeLevels[selectedKnowledgeIndex!];

                                      debugPrint('Learner type: ${learnerTypes[selectedIndex]}');
                                      debugPrint('Knowledge level: $knowledgeLevel');
                                      onboardingStep++;
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: panelTop - mascotSize * 0.78,
                left: 0,
                right: 0,
                height: mascotSize,
                child: IgnorePointer(
                  child: Center(
                    child: Image.asset(
                      'assets/mascot.png',
                      height: mascotSize - 50,
                      width: mascotSize - 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (onboardingStep > 0)
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 26,
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          onboardingStep--;
                        });
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CurvedPanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const curveHeight = 52.0;

    return Path()
      ..moveTo(0, curveHeight)
      ..quadraticBezierTo(size.width / 2, -curveHeight, size.width, curveHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CurvedPanelClipper oldClipper) => false;
}
