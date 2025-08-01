import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RepairmanPartCard extends StatefulWidget {
  final TextEditingController partNameController;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final VoidCallback onRemovePressed;

  const RepairmanPartCard({
    Key? key,
    required this.partNameController,
    required this.quantityController,
    required this.unitPriceController,
    required this.onRemovePressed,
  }) : super(key: key);

  @override
  State<RepairmanPartCard> createState() => _RepairmanPartCardState();
}

class _RepairmanPartCardState extends State<RepairmanPartCard> {
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // محاسبه اولیه هنگام لود
    _updateTotalPrice();

    // گوش دادن به تغییرات
    widget.quantityController.addListener(_updateTotalPrice);
    widget.unitPriceController.addListener(_updateTotalPrice);
  }

  @override
  void dispose() {
    _priceController.dispose();
    widget.quantityController.removeListener(_updateTotalPrice);
    widget.unitPriceController.removeListener(_updateTotalPrice);
    super.dispose();
  }

  void _updateTotalPrice() {
    final quantity = int.tryParse(widget.quantityController.text) ?? 0;
    final unitPrice = double.tryParse(widget.unitPriceController.text) ?? 0.0;
    final totalPrice = quantity * unitPrice;
    _priceController.text = totalPrice.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Part Name
            TextField(
              controller: widget.partNameController,
              decoration: const InputDecoration(
                labelText: 'Part Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),

            // Quantity and Unit Price
            Row(
              children: [
                // Quantity
                Expanded(
                  child: TextField(
                    controller: widget.quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Unit Price
                Expanded(
                  child: TextField(
                    controller: widget.unitPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Remove Button
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(MdiIcons.trashCan, color: Colors.red),
                onPressed: widget.onRemovePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
