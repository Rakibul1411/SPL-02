import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Authentication/registration_screen.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Choose Your Role',
          style: GoogleFonts.montserrat(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to InsightHive',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how you want to use our platform',
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildRoleCard(
                      context,
                      title: 'Gig Worker',
                      description: 'Find gigs, manage your schedule, track earnings',
                      icon: Icons.work_outline,
                      gradient: const [Color(0xFF00C6FB), Color(0xFF005BEA)], // Blue Gradient
                      role: 'Gig Worker',
                    ),
                    _buildRoleCard(
                      context,
                      title: 'Company',
                      description: 'Post jobs, manage teams, track projects',
                      icon: Icons.business,
                      gradient: const [Color(0xFF00DBDE), Color(0xFFFC00FF)], // Teal to Purple Gradient
                      role: 'Company',
                    ),
                    _buildRoleCard(
                      context,
                      title: 'Shop Manager',
                      description: 'Manage inventory, track sales, handle staff',
                      icon: Icons.store,
                      gradient: const [Color(0xFFFF7E5F), Color(0xFFFEB47B)], // Orange Gradient
                      role: 'Shop Manager',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required List<Color> gradient,
        required String role,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrationScreenWithRole(selectedRole: role),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.openSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modified Registration Screen that accepts a role
class RegistrationScreenWithRole extends StatefulWidget {
  final String selectedRole;

  const RegistrationScreenWithRole({
    super.key,
    required this.selectedRole,
  });

  @override
  _RegistrationScreenWithRoleState createState() => _RegistrationScreenWithRoleState();
}

class _RegistrationScreenWithRoleState extends State<RegistrationScreenWithRole> {
  @override
  Widget build(BuildContext context) {
    return RegistrationScreen(preselectedRole: widget.selectedRole);
  }
}