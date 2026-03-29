import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductManagerScreen extends StatefulWidget {
  const ProductManagerScreen({super.key});

  @override
  State<ProductManagerScreen> createState() => _ProductManagerScreenState();
}

class _ProductManagerScreenState extends State<ProductManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Manager"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Fabrics"),
            Tab(text: "Yarns"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductList(type: "FABRIC"),
          ProductList(type: "YARN"),
        ],
      ),

      // ✅ FAB moved here (correct place)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentType =
              _tabController.index == 0 ? "FABRIC" : "YARN";

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(type: currentType),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/* ================= PRODUCT LIST ================= */

class ProductList extends StatelessWidget {
  final String type;
  const ProductList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: type == "FABRIC"
          ? ApiService.getFabrics()
          : ApiService.getYarnMaster(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data as List;

        if (products.isEmpty) {
          return const Center(child: Text("No products found"));
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final p = products[index];

            final title = type == "FABRIC"
                ? (p['name'] ?? '')
                : (p['yarn_name'] ?? '');

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: type == "YARN"
                    ? Text(
                        "Count: ${p['yarn_count'] ?? '-'}  |  Type: ${p['yarn_type'] ?? '-'}",
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}

/* ================= ADD PRODUCT ================= */

class AddProductScreen extends StatefulWidget {
  final String type;
  const AddProductScreen({super.key, required this.type});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _count = TextEditingController();
  final _yarnType = TextEditingController();

  bool loading = false;

  void submit() async {
  if (_name.text.isEmpty) return;

  setState(() => loading = true);

  try {
    if (widget.type == "FABRIC") {
      await ApiService.addFabric(
        name: _name.text.trim(),
      );
    } else {
      await ApiService.addYarn(
        yarnName: _name.text.trim(),
        yarnCount: _count.text.trim(),
        yarnType: _yarnType.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }

  if (mounted) setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add ${widget.type}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.type == "YARN") ...[
              const SizedBox(height: 16),
              TextField(
                controller: _count,
                decoration: const InputDecoration(
                  labelText: "Yarn Count",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _yarnType,
                decoration: const InputDecoration(
                  labelText: "Yarn Type",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
