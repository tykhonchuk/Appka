import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/family_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  @override
  void initState() {
    super.initState();
    // pobieramy listę podopiecznych po wejściu na ekran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FamilyCubit>().fetchFamilyMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: przejście do ekranu dodawania podopiecznego
          // context.push(PagesRoute.addFamilyMemberPage.path);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔵 Nagłówek
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
              padding: EdgeInsets.fromLTRB(15, 30, 15, 5),
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

          // 📋 Kafelki członków rodziny
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: BlocBuilder<FamilyCubit, FamilyState>(
                builder: (context, state) {
                  if (state is FamilyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FamilyError) {
                    return Center(
                      child:
                      Text(state.message ?? "Błąd pobierania podopiecznych"),
                    );
                  } else if (state is FamilyLoaded) {
                    final members = state.members;

                    if (members.isEmpty) {
                      return const Center(
                        child: Text("Brak podopiecznych"),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
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
                            context.push(
                              PagesRoute.familyMemberPage.path,
                              extra: member,
                            );
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
                                  child: const Text("👤",
                                      style: TextStyle(fontSize: 20)),
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
                                      : "${member['documents_count']} dokumenty",
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
                    // FamilyInitial itd.
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
