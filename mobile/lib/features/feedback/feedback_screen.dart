import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../l10n/app_translations.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  String _feedbackType = 'bug';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get device information
      String platform = 'unknown';
      if (Platform.isIOS) {
        platform = 'ios';
      } else if (Platform.isAndroid) {
        platform = 'android';
      }

      final body = {
        'feedback_type': _feedbackType,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'platform': platform,
        'app_version': '1.0.0', // TODO: Get from package_info
      };

      if (_emailController.text.trim().isNotEmpty) {
        body['user_email'] = _emailController.text.trim();
      }
      if (_nameController.text.trim().isNotEmpty) {
        body['user_name'] = _nameController.text.trim();
      }

      // TODO: Replace with actual API endpoint from environment
      final apiUrl = Uri.parse('http://localhost:8000/api/v1/feedback');

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 && mounted) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.of(context, AppText.feedbackSuccess)),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form and go back
        _titleController.clear();
        _descriptionController.clear();
        _emailController.clear();
        _nameController.clear();
        Navigator.of(context).pop();
      } else if (mounted) {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.of(context, AppText.feedbackError)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.of(context, AppText.feedbackError)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context, AppText.feedbackTitle)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Feedback Type
              Text(
                AppTranslations.of(context, AppText.feedbackTypeLabel),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'bug',
                    label: Text(AppTranslations.of(context, AppText.feedbackBugReport)),
                  ),
                  ButtonSegment(
                    value: 'feature',
                    label: Text(AppTranslations.of(context, AppText.feedbackFeatureRequest)),
                  ),
                  ButtonSegment(
                    value: 'general',
                    label: Text(AppTranslations.of(context, AppText.feedbackGeneralFeedback)),
                  ),
                ],
                selected: {_feedbackType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _feedbackType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppTranslations.of(context, AppText.feedbackTitleLabel),
                  hintText: AppTranslations.of(context, AppText.feedbackTitleHint),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTranslations.of(context, AppText.commonRequired);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppTranslations.of(context, AppText.feedbackDescriptionLabel),
                  hintText: AppTranslations.of(context, AppText.feedbackDescriptionHint),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppTranslations.of(context, AppText.commonRequired);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Contact Information (Optional)
              Text(
                AppTranslations.of(context, AppText.feedbackContactLabel),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                AppTranslations.of(context, AppText.feedbackOptionalContact),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 12),

              // Name (Optional)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppTranslations.of(context, AppText.feedbackNameHint),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email (Optional)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppTranslations.of(context, AppText.feedbackEmailHint),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // Basic email validation
                    if (!value.contains('@')) {
                      return AppTranslations.of(context, AppText.commonInvalidEmail);
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              FilledButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppTranslations.of(context, AppText.feedbackSubmit)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
