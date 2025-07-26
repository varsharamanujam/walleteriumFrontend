import 'package:flutter/material.dart';
import 'transaction_card_widget.dart';

// Example global variables for filter/sort/group fields
List<String> filterFields = ['type', 'isAsset', 'subscriptions.rollover_date', 'subscriptions.autopay_enabled'];
List<String> sortFields = ['amount', 'time', 'subscriptions.rollover_date'];
List<String> groupFields = ['type', 'isAsset', 'subscriptions.autopay_enabled'];

// Example data
List<Map<String, dynamic>> sampleTransactions = [
  // 11. Recurring loan payment with benefits (insurance)
  {
    "amount": 15000,
    "time": "2024-07-11T10:00:00",
    "receiver": "Bank of India",
    "type": "debit",
    "transactionId": "TXN12354",
    "isAsset": false,
    "recurring": true,
    "recurringDetails": {
      "type": "loan",
      "frequency": "monthly",
      "next_due": "2024-08-11",
      "principal": 500000,
      "interest_rate": 7.5
    },
    "benefits": {
      "insurance": {
        "type": "life",
        "provider": "LIC",
        "valid_till": "2030-12-31"
      }
    },
  },
  // 12. Recurring rent payment with benefits (maintenance included)
  {
    "amount": 25000,
    "time": "2024-07-12T09:00:00",
    "receiver": "Landlord",
    "type": "debit",
    "transactionId": "TXN12355",
    "isAsset": false,
    "recurring": true,
    "recurringDetails": {
      "type": "rent",
      "frequency": "monthly",
      "next_due": "2024-08-12",
      "maintenance_included": true
    },
    "benefits": {
      "maintenance": {
        "type": "building",
        "provider": "Society",
        "valid_till": "2025-07-12"
      }
    },
  },
  // 13. Recurring mutual fund SIP with benefits (free advisor)
  {
    "amount": 5000,
    "time": "2024-07-13T08:00:00",
    "receiver": "HDFC Mutual Fund",
    "type": "payment",
    "transactionId": "TXN12356",
    "isAsset": true,
    "recurring": true,
    "recurringDetails": {
      "type": "mutual_fund",
      "frequency": "monthly",
      "next_due": "2024-08-13",
      "fund_name": "HDFC Top 100"
    },
    "benefits": {
      "advisor": {
        "type": "financial",
        "provider": "HDFC",
        "valid_till": "2026-07-13"
      }
    },
  },
  // 1. Simple transaction (basic fields)
  {
    "amount": 1200,
    "time": "2024-07-01T14:23:00",
    "receiver": "Alice",
    "type": "credit",
    "transactionId": "TXN12345",
    "isAsset": false,
    "purpose": "Salary",
    "imageUrl": null,
  },
  // 2. Transaction with image and description
  {
    "amount": 500,
    "time": "2024-07-02T09:10:00",
    "receiver": "Bob",
    "type": "debit",
    "transactionId": "TXN12346",
    "isAsset": false,
    "description": "Groceries",
    "imageUrl": "https://placekitten.com/200/200",
  },
  // 3. Asset transaction (shows asset chip)
  {
    "amount": 10000,
    "time": "2024-07-03T18:00:00",
    "receiver": "Mutual Fund",
    "type": "payment",
    "transactionId": "TXN12347",
    "isAsset": true,
    "purpose": "Investment",
    "imageUrl": null,
  },
  // 4. Transaction with nested subscriptions (all fields filled)
  {
    "amount": 299,
    "time": "2024-07-04T10:00:00",
    "receiver": "Netflix",
    "type": "debit",
    "transactionId": "TXN12348",
    "isAsset": false,
    "purpose": "Monthly Subscription",
    "subscriptions": {
      "rollover_date": "2024-08-04",
      "autopay_enabled": true,
      "plan": "Premium"
    },
  },
  // 5. Transaction with nested subscriptions (some nulls, should skip empty)
  {
    "amount": 199,
    "time": "2024-07-05T11:00:00",
    "receiver": "Spotify",
    "type": "debit",
    "transactionId": "TXN12349",
    "isAsset": false,
    "subscriptions": {
      "rollover_date": null,
      "autopay_enabled": false,
      "plan": "Student"
    },
  },
  // 6. Transaction with nested subscriptions (all nulls, should not render subscriptions)
  {
    "amount": 399,
    "time": "2024-07-06T12:00:00",
    "receiver": "Disney+",
    "type": "debit",
    "transactionId": "TXN12350",
    "isAsset": false,
    "subscriptions": {
      "rollover_date": null,
      "autopay_enabled": null,
      "plan": null
    },
  },
  // 7. Transaction with missing amount (shows 'No Amount' warning)
  {
    "time": "2024-07-07T13:00:00",
    "receiver": "Unknown",
    "type": "credit",
    "transactionId": "TXN12351",
    "isAsset": false,
  },
  // 8. Transaction with invalid amount (shows 'Invalid Amount' warning)
  {
    "amount": "notanumber",
    "time": "2024-07-08T14:00:00",
    "receiver": "Test",
    "type": "credit",
    "transactionId": "TXN12352",
    "isAsset": false,
  },
  // 9. Transaction with only nested fields (no top-level receiver/type)
  {
    "amount": 123,
    "time": "2024-07-09T15:00:00",
    "subscriptions": {
      "rollover_date": "2024-09-09",
      "autopay_enabled": true,
      "plan": "Annual"
    },
  },
  // 10. Transaction with deeply nested fields (for future extensibility)
  {
    "amount": 555,
    "time": "2024-07-10T16:00:00",
    "receiver": "Deep Service",
    "type": "debit",
    "transactionId": "TXN12353",
    "isAsset": false,
    "subscriptions": {
      "rollover_date": "2024-10-10",
      "autopay_enabled": true,
      "plan": "Deep",
      "meta": {
        "level": 2,
        "notes": "This is a deeply nested field"
      }
    },
  },
];

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<Map<String, dynamic>> transactions = List.from(sampleTransactions);
  List<Map<String, dynamic>> filtered = [];
  Map<String, dynamic> appliedFilters = {};
  String? sortBy;
  bool sortAsc = true;
  String? groupBy;

  @override
  void initState() {
    super.initState();
    _applyFiltersSortGroup();
  }

  // --- Helper to get nested field value by dot notation ---
  dynamic _getNestedField(Map<String, dynamic> map, String field) {
    if (!field.contains('.')) return map[field];
    var parts = field.split('.');
    dynamic val = map;
    for (var p in parts) {
      if (val is Map<String, dynamic> && val.containsKey(p)) {
        val = val[p];
      } else {
        return null;
      }
    }
    return val;
  }

  void _applyFiltersSortGroup() {
    List<Map<String, dynamic>> temp = List.from(transactions);

    // Apply filters (support nested fields)
    appliedFilters.forEach((field, value) {
      temp = temp.where((t) => _getNestedField(t, field) == value).toList();
    });

    // Sort (support nested fields)
    if (sortBy != null) {
      temp.sort((a, b) {
        final va = _getNestedField(a, sortBy!);
        final vb = _getNestedField(b, sortBy!);
        if (va is Comparable && vb is Comparable) {
          return sortAsc ? va.compareTo(vb) : vb.compareTo(va);
        }
        return 0;
      });
    }

    setState(() {
      filtered = temp;
    });
  }

  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: filterFields.map((field) {
                      return DropdownButton<String>(
                        hint: Text(field),
                        value: appliedFilters[field],
                        items: [
                          ...{...transactions.map((t) => t[field]?.toString() ?? '')}
                        ].where((v) => v.isNotEmpty).map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            if (val == null || val.isEmpty) {
                              appliedFilters.remove(field);
                            } else {
                              appliedFilters[field] = val;
                            }
                            _applyFiltersSortGroup();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text("Sort By", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: sortFields.map((field) {
                      return ChoiceChip(
                        label: Text(field),
                        selected: sortBy == field,
                        onSelected: (selected) {
                          setState(() {
                            sortBy = selected ? field : null;
                            _applyFiltersSortGroup();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Text("Ascending"),
                      Switch(
                        value: sortAsc,
                        onChanged: (v) {
                          setState(() {
                            sortAsc = v;
                            _applyFiltersSortGroup();
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text("Group By", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: groupFields.map((field) {
                      return ChoiceChip(
                        label: Text(field),
                        selected: groupBy == field,
                        onSelected: (selected) {
                          setState(() {
                            groupBy = selected ? field : null;
                            _applyFiltersSortGroup();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog() async {
    Map<String, dynamic> newTx = {};
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDateTime;
    int timeInputMode = 0; // 0: now, 1: manual, 2: picker
    TextEditingController manualTimeController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Center(
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Add Transaction", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Amount", prefixIcon: Icon(Icons.currency_rupee)),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
                          onSaved: (v) => newTx['amount'] = int.tryParse(v ?? ''),
                        ),
                        SizedBox(height: 12),
                        // --- TIME INPUT ---
                        Text("Time", style: TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            ChoiceChip(
                              label: Row(children: [Icon(Icons.access_time, size: 18), SizedBox(width: 4), Text("Now")]),
                              selected: timeInputMode == 0,
                              onSelected: (_) {
                                timeInputMode = 0;
                                selectedDateTime = DateTime.now();
                                manualTimeController.clear();
                                (ctx as Element).markNeedsBuild();
                              },
                            ),
                            SizedBox(width: 8),
                            ChoiceChip(
                              label: Row(children: [Icon(Icons.edit_calendar, size: 18), SizedBox(width: 4), Text("Manual")]),
                              selected: timeInputMode == 1,
                              onSelected: (_) {
                                timeInputMode = 1;
                                (ctx as Element).markNeedsBuild();
                              },
                            ),
                            SizedBox(width: 8),
                            ChoiceChip(
                              label: Row(children: [Icon(Icons.date_range, size: 18), SizedBox(width: 4), Text("Pick")]),
                              selected: timeInputMode == 2,
                              onSelected: (_) async {
                                timeInputMode = 2;
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  final pickedTime = await showTimePicker(
                                    context: ctx,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    selectedDateTime = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  }
                                }
                                (ctx as Element).markNeedsBuild();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (timeInputMode == 1)
                          TextFormField(
                            controller: manualTimeController,
                            decoration: InputDecoration(
                              labelText: "Enter ISO timestamp or yyyy-MM-dd HH:mm",
                              prefixIcon: Icon(Icons.edit),
                            ),
                            onSaved: (v) {
                              if (v != null && v.isNotEmpty) {
                                try {
                                  selectedDateTime = DateTime.parse(v);
                                } catch (_) {
                                  // Try parsing as yyyy-MM-dd HH:mm
                                  try {
                                    final parts = v.split(' ');
                                    if (parts.length == 2) {
                                      final date = parts[0].split('-').map(int.parse).toList();
                                      final time = parts[1].split(':').map(int.parse).toList();
                                      selectedDateTime = DateTime(date[0], date[1], date[2], time[0], time[1]);
                                    }
                                  } catch (_) {}
                                }
                              }
                            },
                          ),
                        if (timeInputMode == 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                            child: Text("Current time will be used.", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ),
                        if (timeInputMode == 2 && selectedDateTime != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, top: 2.0),
                            child: Text("Picked: ${selectedDateTime.toString()}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Receiver", prefixIcon: Icon(Icons.person)),
                          onSaved: (v) => newTx['receiver'] = v,
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: "Type", prefixIcon: Icon(Icons.compare_arrows)),
                          items: ["credit", "debit", "payment"].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                          onChanged: (v) => newTx['type'] = v,
                          onSaved: (v) => newTx['type'] = v,
                        ),
                        SizedBox(height: 12),
                        // --- Extra fields under ExpansionTile ---
                        ExpansionTile(
                          title: Text("More Fields"),
                          children: [
                            TextFormField(
                              decoration: InputDecoration(labelText: "Purpose/Description", prefixIcon: Icon(Icons.notes)),
                              onSaved: (v) => newTx['purpose'] = v,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: "Transaction ID", prefixIcon: Icon(Icons.confirmation_number)),
                              onSaved: (v) => newTx['transactionId'] = v,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: "Image URL", prefixIcon: Icon(Icons.image)),
                              onSaved: (v) => newTx['imageUrl'] = v,
                            ),
                            SwitchListTile(
                              title: Text("Is Asset?"),
                              value: newTx['isAsset'] == true,
                              onChanged: (v) => setState(() => newTx['isAsset'] = v),
                            ),
                            // --- Nested JSON: Subscriptions ---
                            ExpansionTile(
                              title: Text("Subscriptions (nested)"),
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(labelText: "Rollover Date", prefixIcon: Icon(Icons.calendar_month)),
                                  onSaved: (v) {
                                    if (v != null && v.isNotEmpty) {
                                      newTx['subscriptions'] ??= {};
                                      newTx['subscriptions']['rollover_date'] = v;
                                    }
                                  },
                                ),
                                SwitchListTile(
                                  title: Text("Autopay Enabled"),
                                  value: (newTx['subscriptions'] != null && newTx['subscriptions']['autopay_enabled'] == true),
                                  onChanged: (v) {
                                    setState(() {
                                      newTx['subscriptions'] ??= {};
                                      newTx['subscriptions']['autopay_enabled'] = v;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                            SizedBox(width: 12),
                            ElevatedButton(
                              child: Text("Add"),
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  formKey.currentState?.save();
                                  // Save time field
                                  if (timeInputMode == 0) {
                                    newTx['time'] = DateTime.now().toIso8601String();
                                  } else if (selectedDateTime != null) {
                                    newTx['time'] = selectedDateTime!.toIso8601String();
                                  } else {
                                    newTx['time'] = DateTime.now().toIso8601String();
                                  }
                                  setState(() {
                                    transactions.add(Map.from(newTx));
                                    _applyFiltersSortGroup();
                                  });
                                  Navigator.pop(ctx);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
      _applyFiltersSortGroup();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Grouping logic
    Map<String, List<Map<String, dynamic>>> grouped = {};
    if (groupBy != null) {
      for (var tx in filtered) {
        final rawKey = _getNestedField(tx, groupBy!);
        final key = (rawKey == null || rawKey.toString() == 'null' || rawKey.toString().isEmpty)
            ? 'Uncategorized'
            : rawKey.toString();
        grouped.putIfAbsent(key, () => []).add(tx);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterSortSheet,
            tooltip: 'Filter/Sort/Group',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: groupBy == null
            ? ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => TransactionCardWidget(
                  transaction: filtered[i],
                  onDelete: () => _deleteTransaction(i),
                  onEdit: () {}, // Implement edit logic as needed
                ),
              )
            : ListView(
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Text(
                          '${groupBy}: ${entry.key}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      ...entry.value.map((tx) => TransactionCardWidget(
                            transaction: tx,
                            onDelete: () {
                              final idx = filtered.indexOf(tx);
                              _deleteTransaction(idx);
                            },
                            onEdit: () {},
                          )),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
