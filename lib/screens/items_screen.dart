import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import 'widgets/item_form.dart';

class ItemsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search items...'),
              onChanged: (value) => itemProvider.search(value),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: itemProvider.filteredItems.length,
              itemBuilder: (ctx, i) {
                final item = itemProvider.filteredItems[i];
                return Card(
                  child: InkWell(
                    onTap: () => _editItem(context, item),
                    onLongPress: () => _deleteItem(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.itemName, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('MRP: ₹${item.mrp.toStringAsFixed(2)}'),
                          Text('Rate: ₹${item.rate.toStringAsFixed(2)}'),
                          Text('Stock: ${item.stockQuantity}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addItem(context),
      ),
    );
  }

  void _addItem(BuildContext context) {
    showDialog(context: context, builder: (_) => Dialog(child: ItemForm()));
  }

  void _editItem(BuildContext context, Item item) {
    showDialog(context: context, builder: (_) => Dialog(child: ItemForm(item: item)));
  }

  void _deleteItem(BuildContext context, Item item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete'),
        content: Text('Delete ${item.itemName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm == true) {
      Provider.of<ItemProvider>(context, listen: false).deleteItem(item.id!);
    }
  }
}