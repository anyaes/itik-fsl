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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stageWidth = constraints.maxWidth;
            final shortScreen = constraints.maxHeight < 700;
            final horizontalPadding = stageWidth < 360 ? 16.0 : 24.0;
            final panelTop =
                (constraints.maxHeight * (shortScreen ? 0.11 : 0.22))
                    .clamp(48.0, 200.0)
                    .toDouble();
            final mascotSize = math.min(
              220.0,
              math.min(stageWidth * 0.46, constraints.maxHeight * 0.26),
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
                ),
                Center(
                  child: SizedBox(
                    width: stageWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
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
                                        child: LayoutBuilder(
                                          builder: (context, pageConstraints) {
                                            final contentWidth = math.min(
                                              560.0,
                                              math.max(
                                                0.0,
                                                pageConstraints.maxWidth -
                                                    horizontalPadding * 2,
                                              ),
                                            );
                                            final verticalPadding = shortScreen
                                                ? 12.0
                                                : 24.0;
                                            final availableGroupHeight = math
                                                .max(
                                                  0.0,
                                                  pageConstraints.maxHeight -
                                                      verticalPadding * 2,
                                                );
                                            final designGroupHeight =
                                                switch (onboardingStep) {
                                                  0 => 620.0,
                                                  1 => 520.0,
                                                  2 => 360.0,
                                                  _ => 1.0,
                                                };
                                            final scale = math
                                                .min(
                                                  1.0,
                                                  math.min(
                                                    contentWidth / 360.0,
                                                    availableGroupHeight /
                                                        designGroupHeight,
                                                  ),
                                                )
                                                .clamp(0.55, 1.0)
                                                .toDouble();

                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: horizontalPadding,
                                                vertical: verticalPadding,
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: contentWidth,
                                                      child: AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 450,
                                                            ),
                                                        switchInCurve:
                                                            Curves.easeOutBack,
                                                        switchOutCurve:
                                                            Curves.easeIn,
                                                        transitionBuilder: (child, animation) {
                                                          final scaleAnimation =
                                                              Tween<double>(
                                                                begin: 0.92,
                                                                end: 1,
                                                              ).animate(
                                                                animation,
                                                              );

                                                          return FadeTransition(
                                                            opacity: animation,
                                                            child: ScaleTransition(
                                                              scale:
                                                                  scaleAnimation,
                                                              child: child,
                                                            ),
                                                          );
                                                        },
                                                        child: switch (onboardingStep) {
                                                          0 => Column(
                                                            key: const ValueKey(
                                                              0,
                                                            ),
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    24 * scale,
                                                              ),
                                                              Text(
                                                                'I am...',
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF002247,
                                                                  ),
                                                                  fontSize:
                                                                      80 *
                                                                      scale,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  height: 0.8,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Choose which best describes you as a learner. There are no right or wrong answers.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF002247,
                                                                  ),
                                                                  fontSize:
                                                                      24 *
                                                                      scale,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  height: 1,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ChoiceCard(
                                                                title:
                                                                    learnerTypes[0],
                                                                subtitle:
                                                                    'I\'m learning FSL to support someone in my household.',
                                                                isSelected:
                                                                    selectedIndex ==
                                                                    0,
                                                                scale: scale,
                                                                onTap: () =>
                                                                    setState(
                                                                      () =>
                                                                          selectedIndex =
                                                                              0,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ChoiceCard(
                                                                title:
                                                                    learnerTypes[1],
                                                                subtitle:
                                                                    'I want to learn FSL to communicate as a need.',
                                                                isSelected:
                                                                    selectedIndex ==
                                                                    1,
                                                                scale: scale,
                                                                onTap: () =>
                                                                    setState(
                                                                      () =>
                                                                          selectedIndex =
                                                                              1,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ChoiceCard(
                                                                title:
                                                                    learnerTypes[2],
                                                                subtitle:
                                                                    'I just want to learn FSL on my own.',
                                                                isSelected:
                                                                    selectedIndex ==
                                                                    2,
                                                                scale: scale,
                                                                onTap: () =>
                                                                    setState(
                                                                      () =>
                                                                          selectedIndex =
                                                                              2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          1 => Column(
                                                            key: const ValueKey(
                                                              1,
                                                            ),
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    24 * scale,
                                                              ),
                                                              Text(
                                                                'How much do you know?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF002247,
                                                                  ),
                                                                  fontSize:
                                                                      80 *
                                                                      scale,
                                                                  height: 0.8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                'Do you know any FSL or are you completely new?',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF002247,
                                                                  ),
                                                                  fontSize:
                                                                      24 *
                                                                      scale,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ChoiceCard(
                                                                title:
                                                                    knowledgeLevels[0],
                                                                subtitle:
                                                                    'Start with the basics and learn step by step.',
                                                                isSelected:
                                                                    selectedKnowledgeIndex ==
                                                                    0,
                                                                scale: scale,
                                                                onTap: () =>
                                                                    setState(
                                                                      () =>
                                                                          selectedKnowledgeIndex =
                                                                              0,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              ChoiceCard(
                                                                title:
                                                                    knowledgeLevels[1],
                                                                subtitle:
                                                                    'Answer a few questions to find your starting point.',
                                                                isSelected:
                                                                    selectedKnowledgeIndex ==
                                                                    1,
                                                                scale: scale,
                                                                onTap: () =>
                                                                    setState(
                                                                      () =>
                                                                          selectedKnowledgeIndex =
                                                                              1,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          2 => Column(
                                                            key: const ValueKey(
                                                              2,
                                                            ),
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    24 * scale,
                                                              ),
                                                              Text(
                                                                'That\'s cool!',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                  color: const Color(
                                                                    0xFF002247,
                                                                  ),
                                                                  fontSize:
                                                                      80 *
                                                                      scale,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              if (selectedKnowledgeIndex ==
                                                                  null)
                                                                const Text(
                                                                  'Choose a knowledge level',
                                                                )
                                                              else if (selectedKnowledgeIndex ==
                                                                  0)
                                                                const Text(
                                                                  'Show content for beginners',
                                                                )
                                                              else
                                                                const Text(
                                                                  'Aaaaaaaaaaaa',
                                                                ),
                                                            ],
                                                          ),
                                                          _ =>
                                                            const SizedBox.shrink(),
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 30),
                                                    SizedBox(
                                                      width: contentWidth,
                                                      child: Button(
                                                        title: 'CONTINUE',
                                                        scale: scale,
                                                        onTap: () => setState(() {
                                                          final knowledgeLevel =
                                                              selectedKnowledgeIndex ==
                                                                  null
                                                              ? 'not selected'
                                                              : knowledgeLevels[selectedKnowledgeIndex!];

                                                          debugPrint(
                                                            'Learner type: ${learnerTypes[selectedIndex]}',
                                                          );
                                                          debugPrint(
                                                            'Knowledge level: $knowledgeLevel',
                                                          );
                                                          onboardingStep++;
                                                        }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: math
                              .max(0.0, panelTop - mascotSize * 0.78)
                              .toDouble(),
                          left: 0,
                          right: 0,
                          height: mascotSize,
                          child: IgnorePointer(
                            child: Center(
                              child: Image.asset(
                                'assets/mascot.png',
                                height: mascotSize * 0.8,
                                width: mascotSize * 0.8,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        if (onboardingStep > 0)
                          Positioned(
                            top: 16,
                            left: 16,
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
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
