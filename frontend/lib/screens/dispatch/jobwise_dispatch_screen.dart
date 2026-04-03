/*import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class JobwiseDispatchScreen extends StatefulWidget {
  final int jobId;

  const JobwiseDispatchScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobwiseDispatchScreen> createState() => _JobwiseDispatchScreenState();
}

class _JobwiseDispatchScreenState extends State<JobwiseDispatchScreen> {

  List<dynamic> rolls = [];
  List<String> selectedRolls = [];

  bool loading = true;
  bool dispatching = false;

  @override
  void initState() {
    super.initState();
    loadRolls();
  }

  Future<void> loadRolls() async {

    try {

      final data = await ApiService.getDispatchRolls(widget.jobId,);

      setState(() {
        rolls = data;
        loading = false;
      });

    } catch (e) {

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

  }

  void toggleRoll(String rollNo) {

    setState(() {

      if (selectedRolls.contains(rollNo)) {
        selectedRolls.remove(rollNo);
      } else {
        selectedRolls.add(rollNo);
      }

    });

  }

  Future<void> dispatch() async {

    if (selectedRolls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one roll")),
      );
      return;
    }

    setState(() => dispatching = true);

    try {

      final selectedData = rolls
          .where((r) => selectedRolls.contains(r['roll_no']))
          .map((r) => {
                "roll_no": r['roll_no'],
                "quantity": r['quantity']
              })
          .toList();

      await ApiService.dispatchRolls(
        jobId: widget.jobId,
        rolls: selectedData,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rolls dispatched successfully")),
      );

      Navigator.pop(context, true);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }

    if (mounted) setState(() => dispatching = false);

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Dispatch Fabric"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rolls.isEmpty
              ? const Center(
                  child: Text(
                    "No rolls available for dispatch",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Padding(

                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      /// ROLLS LIST
                      Expanded(
                        child: ListView.builder(

                          itemCount: rolls.length,

                          itemBuilder: (context, index) {

                            final r = rolls[index];

                            final rollNo = r['roll_no'];
                            final qty = double.tryParse(
                                    r['quantity'].toString()) ??
                                0;

                            final selected =
                                selectedRolls.contains(rollNo);

                            return Container(

                              margin: const EdgeInsets.only(bottom: 12),

                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.shade800),
                              ),

                              child: CheckboxListTile(

                                value: selected,

                                activeColor: const Color(0xFF00BFA6),

                                title: Text(
                                  rollNo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Text(
                                  "${qty.toStringAsFixed(2)} kg",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                onChanged: (_) =>
                                    toggleRoll(rollNo),

                              ),

                            );

                          },

                        ),
                      ),

                      const SizedBox(height: 10),

                      /// DISPATCH BUTTON
                      SizedBox(

                        width: double.infinity,
                        height: 52,

                        child: ElevatedButton.icon(

                          icon: const Icon(Icons.local_shipping),

                          label: dispatching
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Dispatch Selected (${selectedRolls.length})",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                          onPressed:
                              dispatching ? null : dispatch,

                        ),

                      ),

                    ],

                  ),

                ),

    );

  }

}
*/