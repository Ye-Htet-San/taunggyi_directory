import 'package:flutter/material.dart';
import 'package:tgi_directory/config/url_luncher.dart';

class InfoRow extends StatelessWidget {

  final IconData icon;
  final String label;
  final List<String> values;
  final bool isLink;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.values,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                ...values.map((value) {
                  return isLink
                      ? GestureDetector(
                        onTap: () => launchExternalUrl(context,value),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      )
                      : Text(value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
