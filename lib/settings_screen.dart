import 'package:flutter/material.dart';
import 'main.dart';

const appVersion = '1.0.0';
const lastUpdated = 'June 29, 2026';

class SettingsScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: kBlack,
        foregroundColor: kWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kField,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: kGreen.withOpacity(.25)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 78,
                  height: 78,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.sports_soccer,
                    size: 66,
                    color: kGreen,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'KickForm\nBuild your football formation.',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: darkMode,
            activeThumbColor: kGreen,
            title: const Text(
              'Dark Mode',
              style: TextStyle(color: kWhite),
            ),
            secondary: const Icon(Icons.dark_mode_rounded, color: kGreen),
            onChanged: onDarkModeChanged,
          ),
          const Divider(color: Colors.white24),
          const ListTile(
            leading: Icon(Icons.info_rounded, color: kGreen),
            title: Text('App Version', style: TextStyle(color: kWhite)),
            subtitle: Text(appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded, color: kGreen),
            title: const Text('Privacy Policy', style: TextStyle(color: kWhite)),
            trailing: const Icon(Icons.chevron_right_rounded, color: kWhite),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  title: 'Privacy Policy',
                  sections: privacySections,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.article_rounded, color: kGreen),
            title: const Text('Terms & Conditions', style: TextStyle(color: kWhite)),
            trailing: const Icon(Icons.chevron_right_rounded, color: kWhite),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalScreen(
                  title: 'Terms & Conditions',
                  sections: termsSections,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: kBlack,
        foregroundColor: kWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'KickForm $title',
            style: const TextStyle(
              color: kWhite,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Last Updated: $lastUpdated',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          ...sections.map(
                (section) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1A12),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kGreen.withOpacity(.16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      color: kGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.body,
                    style: const TextStyle(
                      color: kWhite,
                      height: 1.55,
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
}

class LegalSection {
  final String title;
  final String body;

  const LegalSection(this.title, this.body);
}

const privacySections = [
  LegalSection(
    '1. Introduction',
    'KickForm is a football formation board app designed to help users create, edit, and organize football tactical formations locally on their device. This Privacy Policy explains how information is handled when using KickForm.',
  ),
  LegalSection(
    '2. Purpose of the App',
    'KickForm allows users to create football formations, choose formation schemes, edit player names, shirt numbers, positions, captain status, and adjust player locations on a digital football pitch.',
  ),
  LegalSection(
    '3. Information Stored in the App',
    'KickForm stores only the information you choose to enter, including formation names, formation schemes, player names, player numbers, positions, captain status, favorite status, and app settings such as dark mode.',
  ),
  LegalSection(
    '4. Local Device Storage',
    'All KickForm data is stored locally on your device using local storage. KickForm does not upload, sync, or transfer your formations or player information to any server controlled by KickForm.',
  ),
  LegalSection(
    '5. No Account Required',
    'KickForm does not require user registration, login credentials, usernames, passwords, email addresses, phone numbers, profile accounts, or identity verification.',
  ),
  LegalSection(
    '6. No Personal Data Collection',
    'KickForm does not intentionally collect personal information such as your real name, address, location, contacts, photos, camera data, microphone data, payment information, government identifiers, or device identifiers.',
  ),
  LegalSection(
    '7. User-Entered Content',
    'You control what you type into formation names and player names. If you choose to enter real names or personal information, that content remains stored locally on your device and is not transmitted to KickForm-controlled services.',
  ),
  LegalSection(
    '8. Football Formation Data',
    'Formation data may include team structure, tactical layout, player positions, player numbers, and pitch coordinates. This information is used only to provide formation editing and display features inside the app.',
  ),
  LegalSection(
    '9. No Cloud Synchronization',
    'KickForm does not provide cloud synchronization, online backup, account recovery, or remote data restoration. If local app data is deleted, KickForm cannot recover it from a server.',
  ),
  LegalSection(
    '10. Offline Usage',
    'KickForm is designed to work offline. Core functionality such as creating formations, editing players, saving boards, and viewing tactical layouts does not require an internet connection.',
  ),
  LegalSection(
    '11. No Analytics',
    'KickForm does not use analytics SDKs or behavioral tracking tools. The app does not track screen views, button taps, formation usage, player edits, or how often you use the app.',
  ),
  LegalSection(
    '12. No Advertising',
    'KickForm does not display advertisements and does not include advertising network SDKs, advertising identifiers, personalized ad systems, or marketing trackers.',
  ),
  LegalSection(
    '13. No Third-Party Sharing',
    'KickForm does not sell, rent, trade, disclose, or share your formation data with third parties. Since the app does not use backend services, your data is not transmitted to KickForm-controlled online systems.',
  ),
  LegalSection(
    '14. Platform Services',
    'Platform providers such as Google Play may process app download, crash, or device-level information according to their own policies. That platform-level information is not controlled by KickForm inside the app.',
  ),
  LegalSection(
    '15. Permissions',
    'KickForm is designed to work without sensitive permissions. It does not require access to your camera, microphone, contacts, location, calendar, SMS, phone calls, or external files for its core functionality.',
  ),
  LegalSection(
    '16. Data Security',
    'Keeping data local reduces privacy risk. Your data is protected by your device security settings, such as screen lock, operating system protections, and device encryption where available.',
  ),
  LegalSection(
    '17. User Control',
    'You can create, edit, favorite, duplicate, and delete formations at any time inside the app. You can also edit player details and change tactical layouts whenever needed.',
  ),
  LegalSection(
    '18. Data Deletion',
    'You can delete individual formations inside the app. You can remove all locally stored KickForm data by clearing app data in your device settings or uninstalling KickForm.',
  ),
  LegalSection(
    '19. Data Retention',
    'Your formation data remains stored locally until you delete it, clear app data, uninstall the app, or reset your device.',
  ),
  LegalSection(
    '20. Children’s Privacy',
    'KickForm is a general football tactics and formation app and is not specifically directed to children. The app does not knowingly collect children’s personal information.',
  ),
  LegalSection(
    '21. Football Disclaimer',
    'KickForm is an organization and tactical board tool only. It does not provide professional coaching, sports medical advice, performance guarantees, betting advice, or official match analysis.',
  ),
  LegalSection(
    '22. Changes to This Privacy Policy',
    'This Privacy Policy may be updated from time to time to reflect app improvements, legal requirements, or store policy updates. Any updated version should accurately describe KickForm’s data practices.',
  ),
  LegalSection(
    '23. Acceptance',
    'By continuing to use KickForm, you acknowledge that you have read and understood this Privacy Policy.',
  ),
  LegalSection(
    '24. Contact Information',
    'If you have questions about this Privacy Policy or KickForm’s local-only data practices, please use the developer contact information listed on the app store page or official project website.',
  ),
];

const termsSections = [
  LegalSection(
    '1. Acceptance of Terms',
    'By downloading, opening, or using KickForm, you agree to these Terms & Conditions. If you do not agree, do not use the app.',
  ),
  LegalSection(
    '2. Description of the App',
    'KickForm helps users create football formation boards, organize player positions, edit player information, and save tactical layouts locally on their device.',
  ),
  LegalSection(
    '3. User Responsibility',
    'You are responsible for the formation names, player names, positions, numbers, and other information you enter into the app.',
  ),
  LegalSection(
    '4. Tactical Tool Only',
    'KickForm is a simple tactical organization tool. It does not guarantee match results, player performance, coaching success, or team improvement.',
  ),
  LegalSection(
    '5. No Professional Advice',
    'KickForm does not provide professional coaching advice, sports medical advice, betting tips, legal advice, or official football association guidance.',
  ),
  LegalSection(
    '6. Local Data Only',
    'KickForm stores data locally and does not provide online backup, account recovery, or cloud synchronization.',
  ),
  LegalSection(
    '7. Accuracy Disclaimer',
    'KickForm displays formations and player positions based on the information you enter. The app cannot verify real player details, tactical accuracy, or match suitability.',
  ),
  LegalSection(
    '8. Acceptable Use',
    'Use KickForm for lawful personal football organization only. Do not misuse, copy, resell, reverse engineer, or interfere with the app.',
  ),
  LegalSection(
    '9. Intellectual Property',
    'KickForm, including its name, interface, design, branding, and related materials, belongs to its developer or rights holder unless otherwise stated.',
  ),
  LegalSection(
    '10. User Content',
    'You remain responsible for any names, labels, or tactical information you enter. Do not enter content that infringes rights, impersonates others, or violates applicable laws.',
  ),
  LegalSection(
    '11. Limitation of Liability',
    'KickForm is provided as-is. The developer is not responsible for lost local data, incorrect formations, tactical decisions, coaching outcomes, match results, or indirect losses.',
  ),
  LegalSection(
    '12. App Availability',
    'KickForm may be updated, changed, interrupted, or removed from distribution over time. Availability may depend on device compatibility and operating system support.',
  ),
  LegalSection(
    '13. Updates',
    'Future updates may improve features, design, compatibility, legal content, or app performance. Continued use means you accept updated terms.',
  ),
  LegalSection(
    '14. Termination',
    'You may stop using KickForm at any time by deleting the app. There is no user account to close.',
  ),
  LegalSection(
    '15. Governing Terms',
    'If any part of these terms is found unenforceable, the remaining sections should continue to apply as allowed by law.',
  ),
  LegalSection(
    '16. Contact',
    'For questions about these Terms & Conditions, use the developer contact listed on the app store page or official project website.',
  ),
];