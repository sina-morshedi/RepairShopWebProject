import 'package:flutter/material.dart';
import '../features/dashboard/backend_services/backend_services.dart';
import '../features/dashboard/models/InventorySaleLogDTO.dart';
import '../features/dashboard/models/CustomerDTO.dart';
import '../utils/helpers/app_helpers.dart';
import 'InventorySaleLogCard.dart';

class InventorySaleLogsForm extends StatefulWidget {
  const InventorySaleLogsForm({super.key});

  @override
  State<InventorySaleLogsForm> createState() => _InventorySaleLogsFormState();
}

class _InventorySaleLogsFormState extends State<InventorySaleLogsForm> {
  final TextEditingController _customerSearchController = TextEditingController();

  List<CustomerDTO> customerSearchResults = [];
  CustomerDTO? selectedCustomer;

  List<InventorySaleLogDTO> customerSaleLogs = [];
  bool isLoadingSaleLogs = false;

  late VoidCallback _customerListener;

  @override
  void initState() {
    super.initState();

    _customerListener = () {
      final keyword = _customerSearchController.text.trim();
      if (keyword.length < 2) {
        setState(() {
          customerSearchResults = [];
          selectedCustomer = null;
          customerSaleLogs = [];
        });
        return;
      }
      _searchCustomers(keyword);
    };

    _customerSearchController.addListener(_customerListener);
  }

  Future<void> _searchCustomers(String keyword) async {
    final response = await CustomerApi().searchCustomerByName(keyword.toUpperCase());
    if (response.status == 'success' && response.data != null) {
      setState(() {
        customerSearchResults = response.data!;
      });
    } else {
      setState(() {
        customerSearchResults = [];
      });
    }
  }

  Future<void> _fetchSaleLogsForCustomer(String customerName) async {
    setState(() {
      isLoadingSaleLogs = true;
      customerSaleLogs = [];
    });

    try {
      final response = await InventorySaleLogApi().searchByCustomerName(customerName);
      if (response.status == 'success' && response.data != null) {
        setState(() {
          customerSaleLogs = response.data!;
        });
      } else {
        setState(() {
          customerSaleLogs = [];
        });
        StringHelper.showErrorDialog(context, response.message ?? 'Kayıt bulunamadı.');
      }
    } catch (e) {
      setState(() {
        customerSaleLogs = [];
      });
      StringHelper.showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        isLoadingSaleLogs = false;
      });
    }
  }

  void _onCustomerSelected(CustomerDTO customer) {
    setState(() {
      selectedCustomer = customer;

      // برای جلوگیری از تکرار سرچ، Listener رو موقتاً حذف و مقدار رو ست کن
      _customerSearchController.removeListener(_customerListener);
      _customerSearchController.text = customer.fullName;
      _customerSearchController.addListener(_customerListener);

      customerSearchResults.clear();
    });

    _fetchSaleLogsForCustomer(customer.fullName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satış Kayıtları')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _customerSearchController,
              decoration: const InputDecoration(
                labelText: 'Müşteri Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            if (customerSearchResults.isNotEmpty)
              Expanded(
                flex: 0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: customerSearchResults.length,
                  itemBuilder: (context, index) {
                    final customer = customerSearchResults[index];
                    return ListTile(
                      title: Text(customer.fullName),
                      subtitle: Text(customer.phone ?? ''),
                      onTap: () => _onCustomerSelected(customer),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            if (isLoadingSaleLogs)
              const Center(child: CircularProgressIndicator())
            else if (customerSaleLogs.isEmpty)
              const Expanded(
                child: Center(child: Text('Kayıt bulunamadı.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: customerSaleLogs.length,
                  itemBuilder: (context, index) {
                    final log = customerSaleLogs[index];
                    return InventorySaleLogDetailCard(
                      customerId: selectedCustomer?.id ?? '',
                      log: log,
                    );
                  },
                ),
              ),

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customerSearchController.removeListener(_customerListener);
    _customerSearchController.dispose();
    super.dispose();
  }
}
