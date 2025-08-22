import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _apiService = ApiService();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  String? _emailError;

  // User data to collect
  Map<String, dynamic> userData = {
    'personalInfo': {},
    'bodyMetrics': {},
    'goals': {},
    'activityLevel': '',
    'dietPreferences': {},
    'credentials': {},
  };

  void _nextStep() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      // Save current step data
      switch (_currentStep) {
        case 0:
          userData['personalInfo'] = values;
          break;
        case 1:
          userData['bodyMetrics'] = values;
          break;
        case 2:
          userData['goals'] = values;
          break;
        case 3:
          userData['activityLevel'] = values['activityLevel'];
          userData['dietPreferences'] = {
            'restrictions': values['dietRestrictions'] ?? [],
            'preferences': values['foodPreferences'] ?? [],
          };
          break;
        case 4:
          // Check email availability before proceeding
          final email = values['email'];
          setState(() => _isCheckingEmail = true);

          try {
            final exists = await _apiService.checkEmailExists(email);
            if (exists) {
              setState(() {
                _emailError = 'An account with this email already exists';
                _isCheckingEmail = false;
              });
              return;
            }
          } catch (e) {
            setState(() {
              _emailError = 'Error checking email availability';
              _isCheckingEmail = false;
            });
            return;
          }

          setState(() => _isCheckingEmail = false);
          userData['credentials'] = values;
          _handleSignup();
          return;
      }

      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _emailError = null; // Clear email error when going back
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);

    try {
      // Combine all user data
      final signupData = {
        'name': userData['personalInfo']['name'],
        'age': int.parse(userData['personalInfo']['age']),
        'gender': userData['personalInfo']['gender'],
        'weight': double.parse(userData['bodyMetrics']['weight']),
        'height': double.parse(userData['bodyMetrics']['height']),
        'targetWeight': double.parse(userData['bodyMetrics']['targetWeight']),
        'fitnessGoal': userData['goals']['fitnessGoal'],
        'weeklyGoal': userData['goals']['weeklyGoal'],
        'activityLevel': userData['activityLevel'],
        'dietRestrictions': userData['dietPreferences']['restrictions'],
        'foodPreferences': userData['dietPreferences']['preferences'],
        'email': userData['credentials']['email'].toLowerCase(),
        'password': userData['credentials']['password'],
      };

      final response = await _apiService.signup(signupData);

      if (response['success'] == true) {
        // Save token
        await ApiService.storage.write(
          key: 'auth_token',
          value: response['token'],
        );

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Welcome, ${userData['personalInfo']['name']}! Account created successfully.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to home
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 0 ? _previousStep : () => context.go('/'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? AppTheme.primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Step ${_currentStep + 1} of 5',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPersonalInfoStep(),
                  _buildBodyMetricsStep(),
                  _buildGoalsStep(),
                  _buildPreferencesStep(),
                  _buildCredentialsStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _currentStep == 0 ? _formKey : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s get to know you better',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'age',
              decoration: InputDecoration(
                labelText: 'Age',
                prefixIcon: const Icon(Icons.cake_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(value);
                if (age == null || age < 13 || age > 120) {
                  return 'Please enter a valid age (13-120)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormBuilderRadioGroup(
              name: 'gender',
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: InputBorder.none,
              ),
              options: const [
                FormBuilderFieldOption(value: 'male', child: Text('Male')),
                FormBuilderFieldOption(value: 'female', child: Text('Female')),
                FormBuilderFieldOption(value: 'other', child: Text('Other')),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select your gender';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _currentStep == 1 ? _formKey : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Body Metrics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us calculate your nutritional needs',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'weight',
                    decoration: InputDecoration(
                      labelText: 'Current Weight (kg)',
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight < 20 || weight > 300) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'height',
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      prefixIcon: const Icon(Icons.height),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height < 100 || height > 250) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'targetWeight',
              decoration: InputDecoration(
                labelText: 'Target Weight (kg)',
                prefixIcon: const Icon(Icons.flag_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Target weight is required';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight < 20 || weight > 300) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _currentStep == 2 ? _formKey : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Goals',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'What would you like to achieve?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FormBuilderRadioGroup(
              name: 'fitnessGoal',
              decoration: const InputDecoration(
                labelText: 'Primary Goal',
                border: InputBorder.none,
              ),
              options: [
                FormBuilderFieldOption(
                  value: 'lose_weight',
                  child: _buildGoalOption(
                    'Lose Weight',
                    'Burn fat and slim down',
                    Icons.trending_down,
                    Colors.orange,
                  ),
                ),
                FormBuilderFieldOption(
                  value: 'gain_muscle',
                  child: _buildGoalOption(
                    'Gain Muscle',
                    'Build strength and mass',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                FormBuilderFieldOption(
                  value: 'maintain',
                  child: _buildGoalOption(
                    'Maintain Weight',
                    'Stay fit and healthy',
                    Icons.balance,
                    Colors.green,
                  ),
                ),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select your goal';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FormBuilderRadioGroup(
              name: 'weeklyGoal',
              decoration: const InputDecoration(
                labelText: 'Weekly Target',
                border: InputBorder.none,
              ),
              options: const [
                FormBuilderFieldOption(
                  value: '0.25',
                  child: Text('0.25 kg/week - Slow & Steady'),
                ),
                FormBuilderFieldOption(
                  value: '0.5',
                  child: Text('0.5 kg/week - Recommended'),
                ),
                FormBuilderFieldOption(
                  value: '0.75',
                  child: Text('0.75 kg/week - Aggressive'),
                ),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select your weekly target';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _currentStep == 3 ? _formKey : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity & Diet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us personalize your plan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FormBuilderRadioGroup(
              name: 'activityLevel',
              decoration: const InputDecoration(
                labelText: 'Activity Level',
                border: InputBorder.none,
              ),
              options: const [
                FormBuilderFieldOption(
                  value: 'sedentary',
                  child: Text('Sedentary - Little or no exercise'),
                ),
                FormBuilderFieldOption(
                  value: 'light',
                  child: Text('Light - Exercise 1-3 days/week'),
                ),
                FormBuilderFieldOption(
                  value: 'moderate',
                  child: Text('Moderate - Exercise 3-5 days/week'),
                ),
                FormBuilderFieldOption(
                  value: 'active',
                  child: Text('Active - Exercise 6-7 days/week'),
                ),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please select your activity level';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FormBuilderCheckboxGroup(
              name: 'dietRestrictions',
              decoration: const InputDecoration(
                labelText: 'Dietary Restrictions (optional)',
                border: InputBorder.none,
              ),
              options: const [
                FormBuilderFieldOption(
                    value: 'vegetarian', child: Text('Vegetarian')),
                FormBuilderFieldOption(value: 'vegan', child: Text('Vegan')),
                FormBuilderFieldOption(
                    value: 'gluten_free', child: Text('Gluten-Free')),
                FormBuilderFieldOption(
                    value: 'dairy_free', child: Text('Dairy-Free')),
                FormBuilderFieldOption(value: 'halal', child: Text('Halal')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: FormBuilder(
        key: _currentStep == 4 ? _formKey : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Secure your personalized fitness plan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _emailError,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                // Clear error when user types
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'password',
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'At least 8 characters with numbers and letters',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$').hasMatch(value)) {
                  return 'Password must contain letters and numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'confirmPassword',
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                final password =
                    _formKey.currentState?.fields['password']?.value;
                if (value != password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FormBuilderCheckbox(
              name: 'terms',
              initialValue: false,
              title: const Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 14),
              ),
              validator: (value) {
                if (value != true) {
                  return 'You must accept the terms to continue';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isLoading || _isCheckingEmail) ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: (_isLoading || _isCheckingEmail)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
}
