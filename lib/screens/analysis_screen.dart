import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../providers/invoice_provider.dart';
import '../providers/item_provider.dart';
import '../providers/biller_provider.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedQuarter = 1;
  List<List<dynamic>> _exportData = [];

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);
    final billerProvider = Provider.of<BillerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Quarterly Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    items: [2025, 2026, 2027]
                        .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v!),
                    decoration: InputDecoration(labelText: 'Year'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedQuarter,
                    items: [1, 2, 3, 4]
                        .map((q) => DropdownMenuItem(value: q, child: Text('Q$q')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedQuarter = v!),
                    decoration: InputDecoration(labelText: 'Quarter'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Monthly sales chart
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMonthlySales().values.fold(0.0, (max, e) => e > max ? e : max) as double,
                  barGroups: _getMonthlySales().entries.map((e) {
                    return BarChartGroupData(
                      x: _monthNumber(e.key),
                      barRods: [BarChartRodData(toY: e.value, width: 15)],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar'];
                          return Text(months[value.toInt() - 1]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Top selling items
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Selling Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getTopItems().length,
                      itemBuilder: (ctx, i) {
                        final entry = _getTopItems()[i];
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Text('${entry.value.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Top customers
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top 5 Customers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getTopCustomers().length,
                      itemBuilder: (ctx, i) {
                        final entry = _getTopCustomers()[i];
                        return ListTile(
                          title: Text(entry.key),
                          trailing: Text('₹${entry.value.toStringAsFixed(2)}'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _exportCSV,
              child: Text('Export Data'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _getMonthlySales() {
    // Dummy implementation – replace with actual data from invoiceProvider
    return {
      'Jan': 15000,
      'Feb': 20000,
      'Mar': 18000,
    };
  }

  int _monthNumber(String month) {
    const months = {'Jan': 1, 'Feb': 2, 'Mar': 3};
    return months[month] ?? 1;
  }

  List<MapEntry<String, double>> _getTopItems() {
    // Dummy data
    return [
      MapEntry('Item A', 25000),
      MapEntry('Item B', 18000),
      MapEntry('Item C', 12000),
    ];
  }

  List<MapEntry<String, double>> _getTopCustomers() {
    // Dummy data
    return [
      MapEntry('Customer X', 35000),
      MapEntry('Customer Y', 28000),
      MapEntry('Customer Z', 22000),
      MapEntry('Customer W', 15000),
      MapEntry('Customer V', 10000),
    ];
  }

  void _exportCSV() async {
    // Prepare data rows
    List<List<dynamic>> rows = [];
    rows.add(['Month', 'Sales']);
    _getMonthlySales().forEach((month, sales) {
      rows.add([month, sales]);
    });
    rows.add([]);
    rows.add(['Top Items']);
    rows.add(['Item', 'Total Sales']);
    _getTopItems().forEach((e) {
      rows.add([e.key, e.value]);
    });
    rows.add([]);
    rows.add(['Top Customers']);
    rows.add(['Customer', 'Total Amount']);
    _getTopCustomers().forEach((e) {
      rows.add([e.key, e.value]);
    });

    String csv = const ListToCsvConverter().convert(rows);
    final path = Directory.systemTemp.path;
    final file = File('$path/analysis_${_selectedYear}_Q$_selectedQuarter.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Analysis Export');
  }
}