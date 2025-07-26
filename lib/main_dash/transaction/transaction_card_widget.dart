import 'package:flutter/material.dart';

class TransactionCardWidget extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCardWidget({
    Key? key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final amount = t['amount'];
    final time = t['time'];
    final receiver = t['receiver'] ?? t['purpose'] ?? t['description'];
    final isCredit = t['type'] == 'credit';
    final isDebit = t['type'] == 'debit';
    final isPayment = t['type'] == 'payment';
    final isAsset = t['isAsset'] == true;
    final isRecurring = t['recurring'] == true || (t['subscriptions'] != null && t['subscriptions']['recurring'] == true);
    final hasBenefits = t['benefits'] != null && t['benefits'] is Map && t['benefits'].isNotEmpty;
    final imgUrl = t['imageUrl'];
    final txId = t['transactionId'];

    // --- IMPROVEMENT: Validate amount ---
    bool validAmount = amount is num && amount != null;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAsset ? Colors.amber[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCredit ? Colors.green : Colors.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Intuitive icon overlays for credit, debit, payment
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base icon: wallet or account
                    Icon(
                      isPayment ? Icons.account_balance : Icons.account_balance_wallet,
                      color: isPayment ? Colors.blue[200] : Colors.brown[200],
                      size: 32,
                    ),
                    // Overlay: arrow for direction
                    if (isCredit)
                      Positioned(
                        right: 2, bottom: 2,
                        child: Transform.rotate(
                          angle: 0.6, // Diagonal down
                          child: Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                        ),
                      )
                    else if (isDebit)
                      Positioned(
                        left: 2, top: 2,
                        child: Transform.rotate(
                          angle: -0.6, // Diagonal up
                          child: Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                        ),
                      )
                    else if (isPayment)
                      Positioned(
                        bottom: 2, right: 2,
                        child: Icon(Icons.swap_horiz, color: Colors.blue, size: 20),
                      )
                  ],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- IMPROVEMENT: Show warning for missing/invalid amount ---
                      if (validAmount)
                        Text(
                          "\u20B9$amount",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
                        )
                      else
                        Text(
                          amount == null ? "No Amount" : "Invalid Amount",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      // --- END IMPROVEMENT ---
                      if (receiver != null && receiver.toString().trim().isNotEmpty)
                        Text(
                          receiver,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      if (time != null && time.toString().trim().isNotEmpty)
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: widget.onEdit,
                  tooltip: "Edit",
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                  tooltip: "Delete",
                ),
              ],
            ),
            Row(
              children: [
                if (isAsset)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 6.0),
                    child: Chip(
                      label: Text("Asset", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.amber[700],
                      avatar: Icon(Icons.savings, color: Colors.white),
                    ),
                  ),
                if (isRecurring)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 6.0),
                    child: Chip(
                      label: Text("Recurring", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.purple[400],
                      avatar: Icon(Icons.repeat, color: Colors.white),
                    ),
                  ),
                if (hasBenefits)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, right: 6.0),
                    child: Chip(
                      label: Text("Benefits", style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.teal[400],
                      avatar: Icon(Icons.verified, color: Colors.white),
                    ),
                  ),
              ],
            ),
            if (_expanded) ...[
              Divider(height: 24),
              // --- IMPROVEMENT: Show nested fields recursively ---
              ..._buildDetailsList(t),
              if (imgUrl != null && imgUrl.toString().trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imgUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              if (txId != null && txId.toString().trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SelectableText(
                    "Transaction ID: $txId",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              // --- IMPROVEMENT: Show message if no additional details ---
              if (_detailsCount(t) == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "No additional details",
                    style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ),
              // --- END IMPROVEMENT ---
            ],
          ],
        ),
      ),
    );
  }

  // --- Recursively build details for nested fields ---
  List<Widget> _buildDetailsList(Map<String, dynamic> map, {int depth = 0}) {
    List<Widget> widgets = [];
    map.forEach((key, value) {
      if (key == 'imageUrl' || value == null || (value is String && value.trim().isEmpty)) return;
      if (value is Map<String, dynamic>) {
        // Only show if at least one subfield is non-null
        if (value.values.any((v) => v != null && (!(v is String) || v.trim().isNotEmpty))) {
          widgets.add(Padding(
            padding: EdgeInsets.only(left: 8.0 * (depth + 1), top: 4, bottom: 2),
            child: Text(
              "$key:",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey[700]),
            ),
          ));
          widgets.addAll(_buildDetailsList(value, depth: depth + 1));
        }
      } else {
        widgets.add(Padding(
          padding: EdgeInsets.only(left: 8.0 * (depth + 1), top: 2, bottom: 2),
          child: Row(
            children: [
              Text(
                "$key: ",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
              Expanded(
                child: Text(
                  "$value",
                  style: TextStyle(color: Colors.grey[900]),
                ),
              ),
            ],
          ),
        ));
      }
    });
    return widgets;
  }

  // --- Count non-empty, non-null details (excluding imageUrl) recursively ---
  int _detailsCount(Map<String, dynamic> map) {
    int count = 0;
    map.forEach((key, value) {
      if (key == 'imageUrl' || value == null || (value is String && value.trim().isEmpty)) return;
      if (value is Map<String, dynamic>) {
        count += _detailsCount(value);
      } else {
        count++;
      }
    });
    return count;
  }
}
