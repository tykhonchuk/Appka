import 'package:flutter/material.dart';

class DocumentsFilterBar extends StatelessWidget {
  final TextEditingController searchController;

  final List<String> doctors;
  final List<String> diagnoses;
  final List<String> documentTypes;

  final List<String> selectedDoctors;
  final List<String> selectedDiagnoses;
  final List<String> selectedTypes;

  final Function(List<String>) onDoctorsChanged;
  final Function(List<String>) onDiagnosesChanged;
  final Function(List<String>) onTypesChanged;

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Function(DateTime?) onDateFromChanged;
  final Function(DateTime?) onDateToChanged;

  const DocumentsFilterBar({
    super.key,
    required this.searchController,
    required this.doctors,
    required this.diagnoses,
    required this.documentTypes,
    required this.selectedDoctors,
    required this.selectedDiagnoses,
    required this.selectedTypes,
    required this.onDoctorsChanged,
    required this.onDiagnosesChanged,
    required this.onTypesChanged,
    required this.dateFrom,
    required this.dateTo,
    required this.onDateFromChanged,
    required this.onDateToChanged,
  });

  void _openFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // lokalne zmienne do dat
        DateTime? _localDateFrom = dateFrom;
        DateTime? _localDateTo = dateTo;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) {
              String _formatDate(DateTime date) {
                final d = date.day.toString().padLeft(2, '0');
                final m = date.month.toString().padLeft(2, '0');
                final y = date.year.toString();
                return "$d/$m/$y";
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // nagłówek z przyciskiem Wyczyść
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filtry",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedDoctors.clear();
                              selectedDiagnoses.clear();
                              selectedTypes.clear();
                              _localDateFrom = null;
                              _localDateTo = null;
                            });
                            onDoctorsChanged([]);
                            onDiagnosesChanged([]);
                            onTypesChanged([]);
                            onDateFromChanged(null);
                            onDateToChanged(null);
                          },
                          child: const Text("Wyczyść"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // LEKARZ
                    ExpansionTile(
                      title: const Text("Lekarz"),
                      children: doctors.map((doctor) {
                        return CheckboxListTile(
                          title: Text(doctor),
                          value: selectedDoctors.contains(doctor),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedDoctors.add(doctor);
                              } else {
                                selectedDoctors.remove(doctor);
                              }
                            });
                            onDoctorsChanged(List<String>.from(selectedDoctors));
                          },
                        );
                      }).toList(),
                    ),

                    // DIAGNOZA
                    ExpansionTile(
                      title: const Text("Diagnoza"),
                      children: diagnoses.map((diagnosis) {
                        return CheckboxListTile(
                          title: Text(diagnosis),
                          value: selectedDiagnoses.contains(diagnosis),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedDiagnoses.add(diagnosis);
                              } else {
                                selectedDiagnoses.remove(diagnosis);
                              }
                            });
                            onDiagnosesChanged(List<String>.from(selectedDiagnoses));
                          },
                        );
                      }).toList(),
                    ),

                    // TYP DOKUMENTU
                    ExpansionTile(
                      title: const Text("Typ dokumentu"),
                      children: documentTypes.map((type) {
                        return CheckboxListTile(
                          title: Text(type),
                          value: selectedTypes.contains(type),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedTypes.add(type);
                              } else {
                                selectedTypes.remove(type);
                              }
                            });
                            onTypesChanged(List<String>.from(selectedTypes));
                          },
                        );
                      }).toList(),
                    ),

                    // DATA od–do
                    ExpansionTile(
                      title: const Text("Data"),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _localDateFrom == null
                                ? "Data od"
                                : "Od: ${_formatDate(_localDateFrom!)}",
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _localDateFrom ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _localDateFrom = picked;
                              });
                              onDateFromChanged(picked);
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            _localDateTo == null
                                ? "Data do"
                                : "Do: ${_formatDate(_localDateTo!)}",
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _localDateTo ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _localDateTo = picked;
                              });
                              onDateToChanged(picked);
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // PRZYCISK ZASTOSUJ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Zastosuj filtry"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // WYSZUKIWANIE
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Wyszukaj dokument...",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // FILTR
          InkWell(
            onTap: () => _openFilterMenu(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.filter_list, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
