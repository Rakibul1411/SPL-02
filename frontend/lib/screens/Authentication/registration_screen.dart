import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/authProvider.dart';
import '../Map/dhakaCityMap.dart';
import 'login_screen.dart';
import '../OTP/otp_screen.dart';
import 'package:latlong2/latlong.dart';

class RegistrationScreen extends StatefulWidget {
  final String? preselectedRole;

  const RegistrationScreen({
    super.key,
    this.preselectedRole,
  });

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  late String _selectedUserType;
  String _userNameLabel = 'Enter your name';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _showPasswordRequirements = false;
  bool _showLocationFields = false;
  LatLng? _selectedLocation;

  final AuthProvider _authProvider = AuthProvider();
  final String passwordPattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';

  // App theme colors
  final Color primaryColor = const Color(0xFF3E64FF);
  final Color secondaryColor = const Color(0xFFF5F7FF);
  final Color accentColor = const Color(0xFF5D7CE4);
  final Color textDarkColor = const Color(0xFF2C3E50);
  final Color textLightColor = const Color(0xFF7F8C8D);
  final Color successColor = const Color(0xFF2ECC71);
  final Color errorColor = const Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _selectedUserType = widget.preselectedRole ?? 'Gig Worker';
    _updateUserNameLabel();

    _passwordFocusNode.addListener(() {
      setState(() {
        _showPasswordRequirements = _passwordFocusNode.hasFocus;
      });
    });
  }

  void _updateUserNameLabel() {
    switch (_selectedUserType) {
      case 'Company':
        _userNameLabel = 'Enter your company name';
        break;
      case 'Shop Manager':
        _userNameLabel = 'Enter your shop name';
        break;
      case 'Gig Worker':
      default:
        _userNameLabel = 'Enter your name';
        break;
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select your location'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      try {
        final response = await _authProvider.registerUser(
          _userNameController.text,
          _emailController.text,
          _passwordController.text,
          _selectedUserType,
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(isRegistration: response['isRegistration'], email: _emailController.text),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $error'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _selectLocation() async {
    final selectedLocation = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => const DhakaMapScreen(),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _selectedLocation = selectedLocation;
        _latitudeController.text = selectedLocation.latitude.toString();
        _longitudeController.text = selectedLocation.longitude.toString();
        _showLocationFields = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            color: textDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textLightColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, secondaryColor],
            stops: const [0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Registration header
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.app_registration_rounded,
                          size: 48,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Join Our Community',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account to get started',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Progress indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 32),

                  // User Type Dropdown
                  _buildUserTypeDropdown(),
                  const SizedBox(height: 20),

                  // User Name Field
                  _buildUserNameField(),
                  const SizedBox(height: 20),

                  // Email Field
                  _buildEmailField(),
                  const SizedBox(height: 20),

                  // Password Field
                  _buildPasswordField(),
                  if (_showPasswordRequirements) _buildPasswordRequirements(),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),

                  // Location Section
                  Text(
                    'Location',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please select your current location on the map',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textLightColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location Selection Button
                  _buildLocationSelectionButton(),
                  const SizedBox(height: 16),

                  // Latitude and Longitude Fields
                  if (_showLocationFields)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildLatitudeField()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildLongitudeField()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Register Button
                  _buildRegisterButton(),
                  const SizedBox(height: 24),

                  // Login Prompt
                  _buildLoginPrompt(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 1 of 2: Account Details',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
            Text(
              '50%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.5,
            minHeight: 8,
            backgroundColor: secondaryColor,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textDarkColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedUserType,
            items: ['Gig Worker', 'Company', 'Shop Manager']
                .map((role) => DropdownMenuItem(
              value: role,
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  color: textDarkColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedUserType = value!;
                _updateUserNameLabel();
              });
            },
            decoration: InputDecoration(
              labelText: 'User Type',
              labelStyle: GoogleFonts.poppins(color: textLightColor),
              prefixIcon: Icon(Icons.person_outline, color: primaryColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            dropdownColor: Colors.white,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _userNameController,
        decoration: InputDecoration(
          labelText: _userNameLabel,
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: _userNameLabel,
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(
            _selectedUserType == 'Company' ? Icons.business : (_selectedUserType == 'Shop Manager' ? Icons.store : Icons.person),
            color: primaryColor,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please ${_userNameLabel.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: 'example@email.com',
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email address';
          }
          if (!EmailValidator.validate(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: 'Create a strong password',
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        obscureText: !_passwordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (!RegExp(passwordPattern).hasMatch(value)) {
            return 'Password must meet all requirements below';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem(
            'At least 8 characters',
            _passwordController.text.length >= 8,
          ),
          _buildRequirementItem(
            'At least one uppercase letter (A-Z)',
            RegExp(r'[A-Z]').hasMatch(_passwordController.text),
          ),
          _buildRequirementItem(
            'At least one lowercase letter (a-z)',
            RegExp(r'[a-z]').hasMatch(_passwordController.text),
          ),
          _buildRequirementItem(
            'At least one number (0-9)',
            RegExp(r'[0-9]').hasMatch(_passwordController.text),
          ),
          _buildRequirementItem(
            'At least one special character (@!%*?&)',
            RegExp(r'[@$!%*?&]').hasMatch(_passwordController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? successColor : textLightColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isMet ? textDarkColor : textLightColor,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          labelStyle: GoogleFonts.poppins(color: textLightColor),
          hintText: 'Re-enter your password',
          hintStyle: GoogleFonts.poppins(color: textLightColor.withOpacity(0.5)),
          prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
          suffixIcon: IconButton(
            icon: Icon(
              _confirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.poppins(color: textDarkColor),
        obscureText: !_confirmPasswordVisible,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm your password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationSelectionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _selectLocation,
        icon: Icon(
          _selectedLocation == null ? Icons.map_outlined : Icons.location_on,
          color: Colors.white,
        ),
        label: Text(
          _selectedLocation == null ? 'Select Your Location on Map' : 'Change Location',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: _selectedLocation == null ? primaryColor : accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildLatitudeField() {
    return TextFormField(
      controller: _latitudeController,
      decoration: InputDecoration(
        labelText: 'Latitude',
        labelStyle: GoogleFonts.poppins(color: textLightColor, fontSize: 12),
        prefixIcon: Icon(Icons.place_outlined, color: accentColor, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(color: textDarkColor, fontSize: 13),
      keyboardType: TextInputType.number,
      readOnly: true,
    );
  }

  Widget _buildLongitudeField() {
    return TextFormField(
      controller: _longitudeController,
      decoration: InputDecoration(
        labelText: 'Longitude',
        labelStyle: GoogleFonts.poppins(color: textLightColor, fontSize: 12),
        prefixIcon: Icon(Icons.place_outlined, color: accentColor, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(color: textDarkColor, fontSize: 13),
      keyboardType: TextInputType.number,
      readOnly: true,
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: GoogleFonts.poppins(color: textLightColor, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Log In',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}