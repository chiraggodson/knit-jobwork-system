import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SettingFabricScreen extends StatefulWidget {
final int jobId;
final int partyId;

const SettingFabricScreen({
super.key,
required this.jobId,
required this.partyId,
});

@override
State<SettingFabricScreen> createState() => _SettingFabricScreenState();
}

class _SettingFabricScreenState extends State<SettingFabricScreen> {
final TextEditingController _quantityController = TextEditingController();

bool loading = false;

void submit() async {
double? qty = double.tryParse(_quantityController.text);

if (qty == null || qty <= 0) {
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Enter valid quantity")));
  return;
}

setState(() => loading = true);

try {
  await ApiService.addSetting(
    jobId: widget.jobId,
    quantity: qty,
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Setting fabric recorded")),
    );
    Navigator.pop(context, true);
  }
} catch (e) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(e.toString())));
}

if (mounted) setState(() => loading = false);


}

@override
void dispose() {
_quantityController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Setting Fabric")),
body: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
const Text(
"Record fabric made during machine setup.",
style: TextStyle(color: Colors.grey),
),
const SizedBox(height: 20),


        TextField(
          controller: _quantityController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: "Setting Quantity (kg)",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : submit,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Add Setting Fabric"),
          ),
        ),
      ],
    ),
  ),
);

}
}
