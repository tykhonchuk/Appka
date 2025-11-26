import 'package:appka/config/pages_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/family_cubit.dart'; // Twój cubit

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FamilyCubit()..fetchFamilyMembers(), // od razu fetch
      child: Scaffold(
        body: Column(
          children: [
            // Nagłówek
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade200],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    offset: const Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Twoi podopieczni",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kafelki członków rodziny z BlocBuilder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<FamilyCubit, FamilyState>(
                  builder: (context, state) {
                    if (state is FamilyLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FamilyError) {
                      return Center(child: Text("error"));
                    } else if (state is FamilyLoaded) {
                      final members = state.members;
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 3 / 2,
                        ),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return InkWell(
                            onTap: () {
                              // context.go(
                              //   PagesRoute.familyMemberPage.path,
                              //   extra: member
                              // );
                              print("Kliknięto ${member['first_name']}");
                              // np. nawigacja do szczegółów
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blueAccent.shade100,
                                    child: const Text("👤", style: TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "${member['first_name']} ${member['last_name']}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    member['documents_count'] == 0
                                        ? "Brak dokumentów"
                                        : member['documents_count'] == 1
                                        ? "1 dokument"
                                        : "${member['documents_count']} dokumenty", // <--- liczba dokumentów
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
