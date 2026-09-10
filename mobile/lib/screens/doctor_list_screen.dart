import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/disease_display.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/doctor.dart';
import '../repositories/consultation_repository.dart';

/// Doctors relevant to the assessment, nearest first.
///
/// Reads from a bundled local asset - no map or directory service - so it
/// works with the network off.
///
/// Two modes. Normally it shows specialists mapped to an identified
/// condition. When the assessment was uncertain, [DoctorListScreen.general]
/// shows general physicians with wording that doesn't pretend a condition
/// was found. That is an explicit mode rather than a fake disease name
/// relying on the lookup's fallback, which would work by accident and
/// break quietly.
class DoctorListScreen extends StatefulWidget {
  /// The identified condition, or null in general-physician mode.
  final String? disease;

  const DoctorListScreen({super.key, required String this.disease});

  const DoctorListScreen.general({super.key}) : disease = null;

  bool get isGeneral => disease == null;

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
      // In general mode the lookup is asked for a specialisation
      // directly rather than a condition.
      final doctors = await _repository
          .getDoctors(widget.disease ?? 'General Physician');
      if (mounted) setState(() { _doctors = doctors; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _copyPhone(String phone, String name) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppText.of(context).doctorCopiedNumber(name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGeneral
            ? AppText.of(context).doctorsGeneralTitle
            : AppText.of(context).doctorsAppBarTitle),
      ),
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
              Text("${AppText.of(context).doctorsLoadError}\n$_error",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _load, child: Text(AppText.of(context).actionRetry)),
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
            widget.isGeneral
                ? AppText.of(context).doctorsNoneGeneral
                : AppText.of(context).doctorsNoneForCondition,
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
                if (widget.isGeneral) ...[
                  Text(AppText.of(context).doctorsGeneralTitle,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(AppText.of(context).doctorsGeneralSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ] else ...[
                  Text(AppText.of(context).doctorsFor,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(diseaseDisplayName(widget.disease!),
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
                const SizedBox(height: 8),
                Text(AppText.of(context).doctorsFoundCount(doctors.length),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppTheme.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppText.of(context).doctorsDemoNotice,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.danger),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    AppText.of(context).doctorsDistanceNote,
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
          label: Text(AppText.of(context).actionBackToAssessment),
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