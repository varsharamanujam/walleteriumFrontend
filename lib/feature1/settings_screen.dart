// lib/main_dash/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart'; // Ensure WalletUsersRecord is accessible
import '/flutter_flow/flutter_flow_widgets.dart'; // For FFButtonWidget
import '/index.dart'; // For AuthHubScreenWidget and other routes
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, required this.displayName, required this.email}) : super(key: key);

  final String displayName;
  final String email;

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  String _selectedPersona = 'Budgetor'; // Default persona
  String _selectedCurrency = '₹ INR'; // Default currency
  Map<String, bool> _assetPreferences = {
    'Real Estate': true,
    'Gold': true,
    'Stocks': true,
    'Vehicles': true,
    'Cryptocurrency': true,
    'Art & Collectibles': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.displayName);
    _loadUserSettings();
  }

  // Function to load user settings from Firestore
  Future<void> _loadUserSettings() async {
    final user = currentUser;
    if (user == null) return;

    try {
      final userDoc = await WalletUsersRecord.collection.doc(user.uid).get();
      if (userDoc.exists) {
        final walletUser = WalletUsersRecord.fromSnapshot(userDoc);
        setState(() {
          _nameController.text = walletUser.displayName;
          _selectedPersona = walletUser.persona.isNotEmpty ? walletUser.persona : 'Budgetor';
          // Load currency preference, fallback to default
          _selectedCurrency = walletUser.currency.isNotEmpty ? walletUser.currency : '₹ INR';

          // Load asset preferences, merge with defaults to ensure all options are present
          if (walletUser.assetPreferences != null) {
            _assetPreferences.forEach((key, value) {
              _assetPreferences[key] = walletUser.assetPreferences![key] ?? value;
            });
          }
        });
      }
    } catch (e) {
      print('Error loading user settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load settings.')),
        );
      }
    }
  }

  // Function to save user settings to Firestore
  Future<void> _saveUserSettings() async {
    final user = currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
      return;
    }

    try {
      final userDocRef = WalletUsersRecord.collection.doc(user.uid);
      await userDocRef.update({
        'display_name': _nameController.text,
        'persona': _selectedPersona,
        'currency': _selectedCurrency, // Save currency preference
        'asset_preferences': _assetPreferences, // Save the map directly
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
        Navigator.pop(context, {
          'displayName': _nameController.text,
          'persona': _selectedPersona,
          'currency': _selectedCurrency, // Return currency preference
          'assetPreferences': _assetPreferences,
        });
      }
    } catch (e) {
      print('Error saving user settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings.')),
        );
      }
    }
  }

  // Function to handle user logout
  Future<void> _logoutUser() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await authManager.signOut();
      if (mounted) {
        context.goNamed(AuthHubScreenWidget.routeName);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Name TextField
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Email ID TextField (uneditable)
            TextField(
              controller: TextEditingController(text: widget.email),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // User Persona Customization
            Text(
              'Your Financial Persona',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPersona,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Persona',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.psychology_alt),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Budgetor',
                  child: Text(
                    'Budgetor',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Aggressive Investor',
                  child: Text(
                    'Aggressive Investor (High risk, high reward)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Long-Term Investor',
                  child: Text(
                    'Long-Term Investor (Steady growth, lower risk)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Saver',
                  child: Text(
                    'Saver (Prioritizes accumulating funds)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'Debt Avoider',
                  child: Text(
                    'Debt Avoider (Focus on minimizing and eliminating debt)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPersona = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Default Currency
            Text(
              'Default Currency',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              isExpanded: true,
              decoration: const InputDecoration( // Removed prefixIcon from here
                labelText: 'Currency',
                border: OutlineInputBorder(),
                // The currency symbol will now be part of the Text in DropdownMenuItem
              ),
              items: const [
                DropdownMenuItem(
                  value: '₹ INR',
                  child: Text('₹ INR (Indian Rupee)'),
                ),
                DropdownMenuItem(
                  value: '\$ USD',
                  child: Text('\$ USD (United States Dollar)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Account Management
            Text(
              'Account Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            FFButtonWidget(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Linking accounts feature coming soon!')),
                );
                // TODO: Implement actual account linking logic
              },
              text: 'Link New Bank Account',
              icon: const Icon(Icons.link),
              options: FFButtonOptions(
                width: double.infinity,
                height: 40,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                textStyle: const TextStyle( // Explicitly set text style
                  color: Colors.black,
                  fontSize: 14.0, // Adjust as needed
                  fontWeight: FontWeight.w500, // Adjust as needed
                ),
                elevation: 0,
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            FFButtonWidget(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload bank statement feature coming soon!')),
                );
                // TODO: Implement actual bank statement upload logic (requires file picker)
              },
              text: 'Upload Bank Statement',
              icon: const Icon(Icons.upload_file),
              options: FFButtonOptions(
                width: double.infinity,
                height: 40,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                textStyle: const TextStyle( // Explicitly set text style
                  color: Colors.black,
                  fontSize: 14.0, // Adjust as needed
                  fontWeight: FontWeight.w500, // Adjust as needed
                ),
                elevation: 0,
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Asset Preferences
            Text(
              'Asset Preferences',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ..._assetPreferences.keys.map((assetType) {
              return CheckboxListTile(
                title: Text(assetType),
                value: _assetPreferences[assetType],
                onChanged: (bool? newValue) {
                  setState(() {
                    _assetPreferences[assetType] = newValue!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Theme.of(context).primaryColor,
              );
            }).toList(),
            const SizedBox(height: 24),

            // Notification Preferences (Placeholder)
            Text(
              'Notification Preferences',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable Daily Summary'),
              value: true, // Placeholder value
              onChanged: (bool value) {
                // TODO: Implement notification preference logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Daily Summary notifications ${value ? 'enabled' : 'disabled'}')),
                );
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            SwitchListTile(
              title: const Text('Budget Overrun Alerts'),
              value: false, // Placeholder value
              onChanged: (bool value) {
                // TODO: Implement notification preference logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget Overrun Alerts ${value ? 'enabled' : 'disabled'}')),
                );
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 32),

            // Save Settings Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveUserSettings,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing before logout button

            // Logout Button
            Center(
              child: FFButtonWidget(
                onPressed: _logoutUser,
                text: 'Log Out',
                icon: const Icon(Icons.logout),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 40,
                  color: Theme.of(context).colorScheme.error, // Use error color for logout
                  textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                  elevation: 2,
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
