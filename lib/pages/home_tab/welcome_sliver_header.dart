import 'package:flutter/material.dart';

class WelcomeSliverHeader extends StatelessWidget {
  final String userFirstName;

  const WelcomeSliverHeader({super.key, required this.userFirstName});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 70,
      //collapsedHeight: 60,
      elevation: 0,
      pinned: false,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 40,   // ⬅️ zwiększony odstęp od góry (było ~16)
            left: 16,
            right: 16,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade700,
                Colors.blueAccent.shade200
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cześć, $userFirstName!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,  // lekko większy
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6), // ⬅️ większy odstęp
              const Text(
                "Miło Cię znowu widzieć",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
