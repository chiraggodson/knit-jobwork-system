import 'package:flutter/material.dart';
import '../services/api_service.dart';

class YarnReturnScreen extends StatefulWidget {
  final int jobId;
  final int partyId;

  const YarnReturnScreen({
    super.key,
    required this.jobId,
    required this.partyId,
  });

  @override
  State<YarnReturnScreen> createState() =>
      _YarnReturnScreenState();
}

class _YarnReturnScreenState
    extends State<YarnReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController =
      TextEditingController();
  final TextEditingController _remarksController =
      TextEditingController();

  List<dynamic> yarnLots = [];
  dynamic selectedLot;

  bool loading = false;
  bool lotLoading = true;

  @override
  void initState() {
    super.initState();
    loadLots();
  }

  Future<void> loadLots() async {
    try {
      final res =
          await ApiService.getJobIssuedYarns(
              widget.jobId);

      setState(() {
        yarnLots = res;
        lotLoading = false;
      });
    } catch (e) {
      setState(() => lotLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to load lots")),
      );
    }
  }

  void submit() async {
    if (!_formKey.currentState!.validate())
      return;

    if (selectedLot == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
        content: Text("Select yarn lot"),
      ));
      return;
    }

    double? qty =
        double.tryParse(_quantityController.text);

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(
        content: Text("Enter valid quantity"),
      ));
      return;
    }

    setState(() => loading = true);

    try {
      await ApiService.returnYarn(
        jobId: widget.jobId,
        yarnLotId: selectedLot['yarn_lot'],
        quantity: qty,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          content: Text(
              "Yarn returned successfully"),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted)
      setState(() => loading = false);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Yarn Return"),
      ),
      body: lotLoading
          ? const Center(
              child:
                  CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.all(20),
              children: [

                /// HEADER CARD
                _card(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Return Yarn To Job",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color: Color(
                              0xFF00BFA6),
                        ),
                      ),
                      const SizedBox(
                          height: 8),
                      Text(
                        "Job ID: ${widget.jobId}",
                        style:
                            const TextStyle(
                                color: Colors
                                    .grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 20),

                /// FORM CARD
                _card(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        /// LOT DROPDOWN
                        DropdownButtonFormField<
                            dynamic>(
                          value:
                              selectedLot,
                          decoration:
                              const InputDecoration(
                            labelText:
                                "Select Yarn Lot",
                            border:
                                OutlineInputBorder(),
                          ),
                          items: yarnLots
                              .map((lot) {
                            final yarnName =
                                lot['yarn_name'] ??
                                    '';
                            final lotNo =
                                lot['lot_no'] ??
                                    '';
                            final balance =
                                double.tryParse(
                                        lot['balance']
                                            .toString()) ??
                                    0;

                            return DropdownMenuItem(
                              value: lot,
                              child: Text(
                                "$yarnName | Lot: $lotNo | Balance: ${balance.toStringAsFixed(2)} kg",
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged:
                              (val) {
                            setState(() {
                              selectedLot =
                                  val;
                            });
                          },
                        ),

                        const SizedBox(
                            height: 20),

                        /// QUANTITY
                        TextFormField(
                          controller:
                              _quantityController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                                  decimal:
                                      true),
                          decoration:
                              const InputDecoration(
                            labelText:
                                "Return Quantity (kg)",
                            border:
                                OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v ==
                                              null ||
                                          v
                                              .isEmpty
                                      ? "Required"
                                      : null,
                        ),

                        const SizedBox(
                            height: 16),

                        /// REMARKS
                        TextFormField(
                          controller:
                              _remarksController,
                          maxLines: 2,
                          decoration:
                              const InputDecoration(
                            labelText:
                                "Remarks (optional)",
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(
                            height: 24),

                        /// BUTTON
                        SizedBox(
                          width: double
                              .infinity,
                          height: 52,
                          child:
                              ElevatedButton(
                            onPressed:
                                loading
                                    ? null
                                    : submit,
                            child: loading
                                ? const SizedBox(
                                    height:
                                        20,
                                    width:
                                        20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Text(
                                    "Return Yarn",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      letterSpacing:
                                          1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            const Color(0xFF1E1E1E),
        borderRadius:
            BorderRadius.circular(
                12),
        border: Border.all(
            color:
                Colors.grey.shade800),
      ),
      child: child,
    );
  }
}