import 'package:flutter/material.dart';

class ChoiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard>{
  bool isHovered = false;
    
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child:GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isSelected ? const Color(0xFF4EBFD0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isSelected ? const Color(0xFF1EA8C3) : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected ? const Color(0xFF1EA8C3) : Colors.grey.shade300,
              blurRadius: 0,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title, 
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: widget.isSelected ? Colors.white : const Color(0xFF002247),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 0,
                          offset: const Offset(2,2),
                        ),
                      ],
                      )),
                  Text(
                    widget.subtitle, 
                    style: TextStyle(
                      height: 1.0,
                      fontSize: 24, 
                      color: widget.isSelected ? Colors.white : const Color(0xFF002247),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 0,
                          offset: const Offset(2,2),
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
  );  
}
}