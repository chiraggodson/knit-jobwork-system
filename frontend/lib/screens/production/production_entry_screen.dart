import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductionEntryScreen extends StatefulWidget {
  final int jobId;
  final String jobNo;

  const ProductionEntryScreen({
    super.key,
    required this.jobId,
    required this.jobNo,
  });

  @override
  State<ProductionEntryScreen> createState() =>
      _ProductionEntryScreenState();
}

class _ProductionEntryScreenState
    extends State<ProductionEntryScreen> {

  final List<TextEditingController> _weights = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() {
      _weights.add(TextEditingController());
    });
  }

  void _removeRow(int index) {
    setState(() {
      _weights.removeAt(index);
    });
  }

  Future<void> _saveProduction() async {

    List<double> weights = [];

    for (var c in _weights) {
      final val = double.tryParse(c.text);
      if (val != null && val > 0) {
        weights.add(val);
      }
    }

    if (weights.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter at least one roll")),
      );
      return;
    }

    try {

      print("SENDING => jobId: ${widget.jobId}, weights: $weights");

      await ApiService.addProduction(
   widget.jobId,
   weights,
);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Production saved")),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Add Production - ${widget.jobNo}"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addRow,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Row(
              children: const [

                Expanded(
                  flex: 2,
                  child: Text(
                    "Roll",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Text(
                    "Weight (kg)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(width: 40)

              ],
            ),

            const SizedBox(height: 10),

            Expanded(

              child: ListView.builder(
                itemCount: _weights.length,
                itemBuilder: (context, index){

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(
                            vertical: 6),

                    child: Row(
                      children: [

                        Expanded(
                          flex: 2,
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                                fontSize: 16),
                          ),
                        ),

                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller:
                                _weights[index],
                            keyboardType:
                                TextInputType.number,
                            decoration:
                                const InputDecoration(
                              hintText: "Enter weight",
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                              Icons.delete,
                              color: Colors.red),
                          onPressed: (){
                            _removeRow(index);
                          },
                        )

                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: _saveProduction,
                child:
                    const Text("SAVE PRODUCTION"),
              ),
            )

          ],
        ),
      ),
    );
  }
}