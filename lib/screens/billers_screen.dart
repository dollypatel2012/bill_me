import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/biller.dart';
import '../providers/biller_provider.dart';
import 'widgets/biller_form.dart';

class BillersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final billerProvider = Provider.of<BillerProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Billers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search billers...'),
              onChanged: (value) => billerProvider.search(value),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
              ),
              itemCount: billerProvider.filteredBillers.length,
              itemBuilder: (ctx, i) {
                final biller = billerProvider.filteredBillers[i];
                return Card(
                  child: ListTile(
                    title: Text(biller.name),
                    subtitle: Text(biller.customerCode),
                    onTap: () => _editBiller(context, biller),
                    onLongPress: () => _deleteBiller(context, biller),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addBiller(context),
      ),
    );
  }

  void _addBiller(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(child: BillerForm()),
    );
  }

  void _editBiller(BuildContext context, Biller biller) {
    showDialog(
      context: context,
      builder: (_) => Dialog(child: BillerForm(biller: biller)),
    );
  }

  void _deleteBiller(BuildContext context, Biller biller) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete'),
        content: Text('Delete ${biller.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      Provider.of<BillerProvider>(context, listen: false).deleteBiller(biller.id!);
    }
  }
}