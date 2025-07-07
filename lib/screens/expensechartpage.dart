import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseChartPage extends StatelessWidget {
  final Map<String, double> userContributions;

  // Constructor to receive user contributions data
  ExpenseChartPage({required this.userContributions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Padding around the chart
        child: PieChart(
          PieChartData(
            sections: userContributions.entries.map((entry) {
              return PieChartSectionData(
                value: entry.value,  // Contribution amount
                title: "${entry.key}: ₹${entry.value.toStringAsFixed(2)}",  // Name and amount
                color: Colors.primaries[userContributions.keys.toList().indexOf(entry.key) % Colors.primaries.length],  // Dynamic color based on participant
                radius: 60,  // Radius of the pie chart
                titleStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,  // White text color for the title
                ),
              );
            }).toList(),
            borderData: FlBorderData(show: false),  // Hide the border
            sectionsSpace: 2,  // Space between sections
          ),
        ),
      ),
    );
  }
}
