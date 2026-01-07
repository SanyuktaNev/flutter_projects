import 'package:flutter/material.dart';
import '../models/lead_status.dart';
import '../services/lead_service.dart';

class LeadStatusPage extends StatefulWidget {
  const LeadStatusPage({super.key});

  @override
  State<LeadStatusPage> createState() => _LeadStatusPageState();
}

class _LeadStatusPageState extends State<LeadStatusPage> {
  final LeadStatusService _service = LeadStatusService();

  List<LeadStatus> leadStatuses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeadStatuses();
  }

  Future<void> fetchLeadStatuses() async {
    setState(() => isLoading = true);

    final result = await _service.getLeadStatuses();
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        leadStatuses = result['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Failed')),
      );
    }
  }

  Future<void> showAddEditDialog({LeadStatus? leadStatus}) async {
    final controller = TextEditingController(text: leadStatus?.name ?? '');
    final isEdit = leadStatus != null;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Lead Status' : 'Add Lead Status'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (ok != true || controller.text.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = isEdit
        ? await _service.editLeadStatus(
            leadStatus.id!,
            controller.text.trim(),
          )
        : await _service.addLeadStatus(controller.text.trim());

    if (!mounted) return;
    Navigator.pop(context); // close loader

    if (result['success'] == true) {
      fetchLeadStatuses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteLeadStatus(LeadStatus leadStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete'),
        content: Text('Delete "${leadStatus.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm != true) return;

    final result = await _service.deleteLeadStatus(leadStatus.id!);
    if (!mounted) return;

    if (result['success'] == true) {
      fetchLeadStatuses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF9C27B0),
      title: const Text(
        'Lead Status',
        style: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    // ✅ SAME GRADIENT AS LOGIN SCREEN
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : leadStatuses.isEmpty
              ? const Center(
                  child: Text(
                    "No lead statuses found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchLeadStatuses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: leadStatuses.length,
                    itemBuilder: (context, index) {
                      final leadStatus = leadStatuses[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(leadStatus.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    showAddEditDialog(leadStatus: leadStatus),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    deleteLeadStatus(leadStatus),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    ),

    // ✅ PURPLE FAB
    floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xFF9C27B0),
      onPressed: () => showAddEditDialog(),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );
}

}
