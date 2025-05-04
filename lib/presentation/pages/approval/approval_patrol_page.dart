import 'package:flutter/material.dart';

class ApprovalPatrolPage extends StatelessWidget {
  const ApprovalPatrolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrol Approvals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Example data; replace with actual data
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('Patrol #${index + 1}'),
                    subtitle: const Text('Awaiting Review'),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        // Implement approval logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Approved Patrol #${index + 1}')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
