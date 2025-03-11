import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Authentication/login_screen.dart';
import 'launch_page_screen.dart';

class AfterRegistrationScreen extends StatefulWidget {
  const AfterRegistrationScreen({super.key});

  @override
  State<AfterRegistrationScreen> createState() => _AfterRegistrationScreenState();
}

class _AfterRegistrationScreenState extends State<AfterRegistrationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHoveringLogin = false;
  bool _isHoveringHome = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.fastOutSlowIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(
            color: Color(0xFF4272FF), // Apply the #4272FF color (blue)
          ),

          // Decorative Elements
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Success Icon and Branding Section
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Hero(
                            tag: 'app-logo',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                size: 50,
                                color: Color(0xFF4272FF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Welcome to InsightHive!',
                            style: GoogleFonts.poppins(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Your account has been successfully created',
                            style: GoogleFonts.poppins(
                              fontSize: 16.0,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.5,
                              height: 1.5,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24.0),

                          // Added Feature Row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFeatureIcon(Icons.connect_without_contact),
                              const SizedBox(width: 8),
                              Text(
                                'Connect',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureIcon(Icons.people_alt_outlined),
                              const SizedBox(width: 8),
                              Text(
                                'Collaborate',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFeatureIcon(Icons.emoji_events_outlined),
                              const SizedBox(width: 8),
                              Text(
                                'Succeed',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Buttons Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildButton(
                            text: 'Log In',
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOutCubic;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            ),
                            isPrimary: true,
                            onHover: (isHovering) {
                              setState(() {
                                _isHoveringLogin = isHovering;
                              });
                            },
                            isHovering: _isHoveringLogin,
                            icon: Icons.login_rounded,
                          ),
                          const SizedBox(height: 16.0),
                          _buildButton(
                            text: 'Return Home',
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => const LaunchScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOutCubic;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 600),
                              ),
                            ),
                            isPrimary: false,
                            onHover: (isHovering) {
                              setState(() {
                                _isHoveringHome = isHovering;
                              });
                            },
                            isHovering: _isHoveringHome,
                            icon: Icons.home_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Terms and Privacy
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 12.0,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
    required Function(bool) onHover,
    required bool isHovering,
    required IconData icon,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: isPrimary
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isHovering ? Color(0xFF3270FF) : Color(0xFF4272FF),
          boxShadow: [
            BoxShadow(
              color: isHovering ? Color(0xFF3270FF).withOpacity(0.7) : Color(0xFF4272FF).withOpacity(0.3),
              blurRadius: isHovering ? 15 : 10,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        )
            : BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isHovering ? Colors.grey[600] : Colors.grey[700],
          border: Border.all(
            color: isHovering ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isHovering
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onPressed,
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}