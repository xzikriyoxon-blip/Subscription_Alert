import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/premium_providers.dart';
import 'settings_screen.dart';

/// Screen for managing referrals and inviting friends.
///
/// Shows the user's referral code, referral stats, and allows
/// entering a referral code to get premium rewards.
class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _isApplyingCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final profile = ref.watch(userProfileProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final premiumDays = ref.watch(premiumDaysRemainingProvider);
    final isLifetime = ref.watch(isLifetimePremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.inviteFriends),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium status card
            _buildPremiumStatusCard(context, isPremium, premiumDays, isLifetime, strings),
            const SizedBox(height: 24),

            // Your referral code section
            _buildReferralCodeSection(context, profile?.referralCode ?? '', strings),
            const SizedBox(height: 24),

            // How it works section
            _buildHowItWorksSection(context, strings),
            const SizedBox(height: 24),

            // Stats section
            _buildStatsSection(context, profile?.totalReferrals ?? 0, strings),
            const SizedBox(height: 24),

            // Enter referral code section (only if user hasn't used one)
            if (profile?.referredBy == null)
              _buildEnterCodeSection(context, strings),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumStatusCard(
    BuildContext context,
    bool isPremium,
    int daysRemaining,
    bool isLifetime,
    dynamic strings,
  ) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isPremium
                ? [Colors.amber[600]!, Colors.orange[400]!]
                : [Colors.grey[600]!, Colors.grey[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isPremium ? Icons.star : Icons.star_border,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              isPremium ? strings.premiumActive : strings.freePlan,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (isPremium)
              Text(
                isLifetime ? strings.lifetimePremium : strings.daysRemaining(daysRemaining),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            if (!isPremium)
              Text(
                strings.inviteToGetPremium,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeSection(BuildContext context, String code, dynamic strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.yourReferralCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Code display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code.isEmpty ? '--------' : code,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: code.isEmpty ? null : () => _copyCode(code),
                    icon: const Icon(Icons.copy),
                    label: Text(strings.copyCode),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: code.isEmpty ? null : () => _shareCode(code, strings),
                    icon: const Icon(Icons.share),
                    label: Text(strings.share),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context, dynamic strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.howItWorks,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStep(
              icon: Icons.share,
              title: strings.step1Title,
              description: strings.step1Description,
              number: '1',
            ),
            _buildStep(
              icon: Icons.person_add,
              title: strings.step2Title,
              description: strings.step2Description,
              number: '2',
            ),
            _buildStep(
              icon: Icons.star,
              title: strings.step3Title,
              description: strings.step3Description,
              number: '3',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
    required String number,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, int totalReferrals, dynamic strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                value: totalReferrals.toString(),
                label: strings.friendsInvited,
                icon: Icons.people,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStatItem(
                value: '${totalReferrals * 7}',
                label: strings.daysEarned,
                icon: Icons.calendar_today,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEnterCodeSection(BuildContext context, dynamic strings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.haveReferralCode,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: strings.enterCode,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    maxLength: 12,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isApplyingCode ? null : _applyCode,
                  child: _isApplyingCode
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(strings.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  void _shareCode(String code, dynamic strings) {
    final message = strings.shareMessage(code);
    Share.share(message);
  }

  Future<void> _applyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isApplyingCode = true);

    try {
      final controller = ref.read(premiumControllerProvider);
      if (controller == null) {
        throw Exception('Not logged in');
      }

      final result = await controller.applyReferralCode(code);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );

        if (result.success) {
          _codeController.clear();
        }
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
        setState(() => _isApplyingCode = false);
      }
    }
  }
}
