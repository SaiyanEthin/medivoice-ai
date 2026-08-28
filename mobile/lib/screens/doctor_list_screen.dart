import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/disease_display.dart';
import '../core/theme/app_theme.dart';
import '../models/doctor.dart';
import '../repositories/consultation_repository.dart';

/// Shows doctors relevant to the assessed condition, nearest first.
/// Data comes from a local SQLite database on the backend - no external
/// map/directory service, which keeps this workable offline later.
class DoctorListScreen extends StatefulWidget {
  final String disease;

  const DoctorListScreen({super.key, required this.disease});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final ConsultationRepository _repository = ConsultationRepository();
  List<Doctor>? _doctors;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doctors = await _repository.getDoctors(widget.disease);
      if (mounted) setState(() { _doctors = doctors; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _copyPhone(String phone, String name) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied $name's number")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Doctors")),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 40, color: AppTheme.danger),
              const SizedBox(height: 12),
              Text("Couldn't load doctors.\n$_error",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final doctors = _doctors!;

    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "No doctors found for this condition in the local database.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Doctors for", style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(diseaseDisplayName(widget.disease),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text("${doctors.length} found, nearest first",
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...doctors.map((d) => _DoctorCard(
              doctor: d,
              onCopyPhone: () => _copyPhone(d.phone, d.name),
            )),
        const SizedBox(height: 8),
        Card(
          color: AppTheme.accent.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.primaryDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Sample directory data for demonstration. Distances are "
                    "approximate and not based on your live location.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text("Back to Assessment"),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onCopyPhone;

  const _DoctorCard({required this.doctor, required this.onCopyPhone});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary.withOpacity(0.12),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.primaryDark, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(doctor.specialization,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.primaryDark)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: doctor.isNearby
                        ? AppTheme.success.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${doctor.distanceKm.toStringAsFixed(1)} km",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: doctor.isNearby
                          ? AppTheme.success
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(doctor.district,
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: onCopyPhone,
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(doctor.phone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}