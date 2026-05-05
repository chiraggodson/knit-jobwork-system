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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: "Colors"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductList(type: "FABRIC"),
          ProductList(type: "YARN"),
            ColorList(),
        ],
      ),
    floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final index = _tabController.index;

    if (index == 2) {
      // ✅ COLOR TAB
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddColorScreen(),
        ),
      );

      if (result == true) setState(() {});
    } else {
      // ✅ FABRIC / YARN
      final currentType = index == 0 ? "FABRIC" : "YARN";

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddProductScreen(type: currentType),
        ),
      );

      if (result == true) setState(() {});
    }
  },
  child: const Icon(Icons.add),
),
    );
    }
  }
 

/* ================= PRODUCT LIST ================= */

class ProductList extends StatefulWidget {
  final String type;
  const ProductList({super.key, required this.type});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  List allProducts = [];
  List filteredProducts = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filter);
  }

  Future<void> fetchData() async {
    final data = widget.type == "FABRIC"
        ? await ApiService.getFabrics()
        : await ApiService.getYarnMaster();

    setState(() {
      allProducts = data;
      filteredProducts = data;
      loading = false;
    });
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredProducts = allProducts.where((p) {
        final name = widget.type == "FABRIC"
            ? (p['name'] ?? '').toString().toLowerCase()
            : (p['yarn_name'] ?? '').toString().toLowerCase();

        final count = (p['yarn_count'] ?? '').toString().toLowerCase();
        final type = (p['yarn_type'] ?? '').toString().toLowerCase();

        return name.contains(query) ||
            count.contains(query) ||
            type.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredProducts.isEmpty) {
      return Column(
        children: [
          _buildSearch(),
          const Expanded(
            child: Center(child: Text("No results found")),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildSearch(),
        Expanded(
          child: ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final p = filteredProducts[index];

              final title = widget.type == "FABRIC"
                  ? (p['name'] ?? '')
                  : (p['yarn_name'] ?? '');

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: widget.type == "YARN"
                      ? Text(
                          "Count: ${p['yarn_count'] ?? '-'}  |  Type: ${p['yarn_type'] ?? '-'}",
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search ${widget.type.toLowerCase()}...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
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

      if (mounted) Navigator.pop(context, true);
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
class ColorList extends StatefulWidget {
  const ColorList({super.key});

  @override
  State<ColorList> createState() => _ColorListState();
}

class _ColorListState extends State<ColorList> {
  List allColors = [];
  List filteredColors = [];
  bool loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filter);
  }

  Future<void> fetchData() async {
    final data = await ApiService.getColors();

    setState(() {
      allColors = data;
      filteredColors = data;
      loading = false;
    });
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      filteredColors = allColors.where((c) {
        final name = (c['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredColors.isEmpty) {
      return Column(
        children: [
          _buildSearch(),
          const Expanded(
            child: Center(child: Text("No results found")),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildSearch(),
        Expanded(
          child: ListView.builder(
            itemCount: filteredColors.length,
            itemBuilder: (context, index) {
              final c = filteredColors[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    c['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search colors...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
class AddColorScreen extends StatefulWidget {
  const AddColorScreen({super.key});

  @override
  State<AddColorScreen> createState() => _AddColorScreenState();
}

class _AddColorScreenState extends State<AddColorScreen> {
  final _name = TextEditingController();
  final _code = TextEditingController(); // optional (for hex like #FF0000)

  bool loading = false;

  void submit() async {
    if (_name.text.trim().isEmpty) return;

    setState(() => loading = true);

    try {
      await ApiService.addColor(
        name: _name.text.trim(),
        code: _code.text.trim(), // optional
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Color")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: "Color Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: "Color Code (optional)",
                hintText: "#FF0000",
                border: OutlineInputBorder(),
              ),
            ),
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