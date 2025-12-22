import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/subscription_providers.dart';
import '../providers/premium_providers.dart';
import '../services/pdf_report_service.dart';
import 'settings_screen.dart'; // For stringsProvider

/// Screen for generating PDF reports of subscriptions.
/// This is a PREMIUM feature.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final PDFReportService _pdfService = PDFReportService();
  bool _isGenerating = false;
  File? _generatedFile;

  // Report type selection
  String _selectedReportType = 'monthly';

  // Monthly report settings
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Custom date range settings
  DateTime _customStartDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _customEndDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final subscriptions = ref.watch(subscriptionsProvider);
    final theme = Theme.of(context);
    final strings = ref.watch(stringsProvider);

    // Check premium access
    if (!isPremium) {
      return Scaffold(
        appBar: AppBar(
          title: Text(strings.reports),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Premium Feature',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'PDF Report Generation is a premium feature.\nUpgrade to Premium to access detailed subscription reports.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to premium/payment screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Premium upgrade coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Upgrade to Premium'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reports),
      ),
      body: _buildContent(context, subscriptions),
    );
  }

  Widget _buildContent(BuildContext context, List subscriptions) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Type Selection
          Text(
            'Report Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildReportTypeSelector(context),

          const SizedBox(height: 24),

          // Report Settings based on type
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildReportSettings(context),
          ),

          const SizedBox(height: 32),

          // Preview Card
          _buildPreviewCard(context, subscriptions),

          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isGenerating ? null : () => _generateReport(subscriptions),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label:
                  Text(_isGenerating ? 'Generating...' : 'Generate PDF Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          // Generated file actions
          if (_generatedFile != null) ...[
            const SizedBox(height: 16),
            _buildFileActions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildReportTypeSelector(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'monthly',
          label: Text('Monthly'),
          icon: Icon(Icons.calendar_month),
        ),
        ButtonSegment(
          value: 'yearly',
          label: Text('Yearly'),
          icon: Icon(Icons.calendar_today),
        ),
        ButtonSegment(
          value: 'custom',
          label: Text('Custom'),
          icon: Icon(Icons.date_range),
        ),
      ],
      selected: {_selectedReportType},
      onSelectionChanged: (selection) {
        setState(() {
          _selectedReportType = selection.first;
          _generatedFile = null;
        });
      },
    );
  }

  Widget _buildReportSettings(BuildContext context) {
    switch (_selectedReportType) {
      case 'monthly':
        return _buildMonthlySettings(context);
      case 'yearly':
        return _buildYearlySettings(context);
      case 'custom':
        return _buildCustomSettings(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMonthlySettings(BuildContext context) {
    final months = List.generate(12, (i) => i + 1);
    final years = List.generate(5, (i) => DateTime.now().year - i);

    return Card(
      key: const ValueKey('monthly'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Month & Year',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    items: months.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child:
                            Text(DateFormat('MMMM').format(DateTime(2000, m))),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                        _generatedFile = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                    ),
                    items: years.map((y) {
                      return DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                        _generatedFile = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlySettings(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - i);

    return Card(
      key: const ValueKey('yearly'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Year',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
              ),
              items: years.map((y) {
                return DropdownMenuItem(
                  value: y,
                  child: Text(y.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                  _generatedFile = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSettings(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      key: const ValueKey('custom'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(_customStartDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateFormat.format(_customEndDate)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _customStartDate : _customEndDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      setState(() {
        if (isStart) {
          _customStartDate = selectedDate;
          if (_customStartDate.isAfter(_customEndDate)) {
            _customEndDate = _customStartDate;
          }
        } else {
          _customEndDate = selectedDate;
          if (_customEndDate.isBefore(_customStartDate)) {
            _customStartDate = _customEndDate;
          }
        }
        _generatedFile = null;
      });
    }
  }

  Widget _buildPreviewCard(BuildContext context, List subscriptions) {
    final activeCount = subscriptions.where((s) => !s.isCancelled).length;
    final trialCount =
        subscriptions.where((s) => s.isTrial && !s.isCancelled).length;

    String periodText;
    switch (_selectedReportType) {
      case 'monthly':
        periodText = DateFormat('MMMM yyyy')
            .format(DateTime(_selectedYear, _selectedMonth));
        break;
      case 'yearly':
        periodText = _selectedYear.toString();
        break;
      case 'custom':
        final dateFormat = DateFormat('MMM d, yyyy');
        periodText =
            '${dateFormat.format(_customStartDate)} - ${dateFormat.format(_customEndDate)}';
        break;
      default:
        periodText = '';
    }

    return Card(
      color:
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Report Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _buildPreviewRow('Period', periodText),
            _buildPreviewRow('Active Subscriptions', activeCount.toString()),
            _buildPreviewRow('Trial Subscriptions', trialCount.toString()),
            _buildPreviewRow('Report Type', _selectedReportType.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFileActions(BuildContext context) {
    return Card(
      color: Colors.green.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Report Generated Successfully!',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openReport,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareReport,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport(List subscriptions) async {
    setState(() {
      _isGenerating = true;
      _generatedFile = null;
    });

    try {
      File? file;
      final baseCurrency = ref.read(baseCurrencyProvider);

      switch (_selectedReportType) {
        case 'monthly':
          file = await _pdfService.generateMonthlyReport(
            subscriptions: subscriptions.cast(),
            month: _selectedMonth,
            year: _selectedYear,
            currencyCode: baseCurrency,
          );
          break;
        case 'yearly':
          file = await _pdfService.generateYearlyReport(
            subscriptions: subscriptions.cast(),
            year: _selectedYear,
            currencyCode: baseCurrency,
          );
          break;
        case 'custom':
          file = await _pdfService.generateCustomReport(
            subscriptions: subscriptions.cast(),
            startDate: _customStartDate,
            endDate: _customEndDate,
            currencyCode: baseCurrency,
          );
          break;
      }

      if (file != null && mounted) {
        setState(() {
          _generatedFile = file;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _openReport() async {
    if (_generatedFile != null) {
      await _pdfService.openPDF(_generatedFile!);
    }
  }

  Future<void> _shareReport() async {
    if (_generatedFile != null) {
      await Share.shareXFiles(
        [XFile(_generatedFile!.path)],
        text: 'My Subscription Report',
      );
    }
  }
}
