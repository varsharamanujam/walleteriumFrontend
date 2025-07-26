
import 'package:flutter/material.dart';
// Uncomment if you want to use charts for insights
// import 'package:fl_chart/fl_chart.dart';


class NotificationCardWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final double collapsedHeight;
  final double expandedHeight;
  final VoidCallback? onTap; // --- Added for actionable notifications ---

  const NotificationCardWidget({
    Key? key,
    required this.data,
    this.collapsedHeight = 50,
    this.expandedHeight = 110,
    this.onTap,
  }) : super(key: key);

  @override
  State<NotificationCardWidget> createState() => _NotificationCardWidgetState();
}


class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  bool _expanded = false;

  void _toggleExpand(bool expand) {
    setState(() {
      _expanded = expand;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String type = widget.data['type'] ?? 'insight';
    final String text = widget.data['text'] ?? '';
    final String iconType = widget.data['icon'] ?? 'info';
    final IconData icon = _getIcon(iconType);
    final String? details = widget.data['details'];

    // For extensibility: additional attributes
    final num? statNumber = widget.data['statNumber'];
    final Color? statColor = _getStatColor(widget.data['statColor']);
    // final List<double>? chartData = widget.data['chartData'] != null ? List<double>.from(widget.data['chartData']) : null;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null) {
          if (details.primaryDelta! > 10) _toggleExpand(true); // swipe down
          if (details.primaryDelta! < -10) _toggleExpand(false); // swipe up
        }
      },
      onTap: () {
        // --- If actionable, call onTap, else toggle expand ---
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          _toggleExpand(!_expanded);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _expanded ? widget.expandedHeight : widget.collapsedHeight,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(type),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            //maxLines: _expanded ? 2 : 1,
                            //overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900]),
                          ),
                        ),
                        if (statNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              statNumber.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statColor ?? Colors.deepPurple,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_expanded && details != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                      ),
                    // Example for extensibility: chart for insights
                    // if (_expanded && chartData != null && type == 'insight')
                    //   SizedBox(
                    //     height: 40,
                    //     child: LineChart(
                    //       LineChartData(
                    //         lineBarsData: [
                    //           LineChartBarData(
                    //             spots: List.generate(chartData.length, (i) => FlSpot(i.toDouble(), chartData[i])),
                    //             isCurved: true,
                    //             colors: [Colors.blue],
                    //             barWidth: 2,
                    //           ),
                    //         ],
                    //         titlesData: FlTitlesData(show: false),
                    //         gridData: FlGridData(show: false),
                    //         borderData: FlBorderData(show: false),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ),
              _buildTrailingIcon(type, icon),
            ],
          ),
        ),
      ),
    );
  }


  // Modular trailing icon or action
  Widget _buildTrailingIcon(String type, IconData icon) {
    switch (type) {
      case 'question':
        return IconButton(
          icon: Icon(icon, size: 28, color: Colors.orangeAccent),
          onPressed: () {
            // TODO: Implement navigation or action for question type
            // Example: Navigator.pushNamed(context, '/clarificationPage');
          },
        );
      case 'motivation':
        return Icon(icon, size: 28, color: Colors.green);
      case 'insight':
      default:
        return Icon(icon, size: 28, color: Colors.blueAccent);
    }
  }

  // Border color by notification type
  Color _getBorderColor(String type) {
    switch (type) {
      case 'question':
        return Colors.orangeAccent;
      case 'motivation':
        return Colors.green;
      case 'insight':
      default:
        return Colors.blueAccent;
    }
  }

  // Stat color helper
  Color? _getStatColor(dynamic color) {
    if (color is Color) return color;
    if (color is int) return Color(color);
    if (color is String) {
      try {
        return Color(int.parse(color.replaceFirst('#', '0xff')));
      } catch (_) {}
    }
    return null;
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }
}
