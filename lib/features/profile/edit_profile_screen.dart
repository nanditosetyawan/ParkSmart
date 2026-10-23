import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import 'backend/edit_profile_backend.dart';
import 'backend/profile_backend.dart';

class EditProfileScreen extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;

  const EditProfileScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _birthDateController;
  String _selectedGender = 'Laki-laki';
  bool _isLoading = false;

  String? _profileImageUrl;
  Uint8List? _localAvatarBytes;

  @override
  void initState() {
    super.initState();
    final p = ProfileBackend.instance;
    _nameController = TextEditingController(text: widget.initialName ?? p.name);
    _emailController = TextEditingController(text: widget.initialEmail ?? p.email);
    _phoneController = TextEditingController(text: widget.initialPhone ?? p.phone);
    _addressController = TextEditingController(text: '');
    _birthDateController = TextEditingController(text: '');
    _profileImageUrl = p.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    DateTime initial = DateTime(2000, 1, 1);
    if (_birthDateController.text.isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(_birthDateController.text);
        if (parsed != null) initial = parsed;
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = ThemeService.instance.isDarkMode;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF15803D),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E232B),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF15803D),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showToast('Nama lengkap tidak boleh kosong'.tr, isError: true);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showToast('Format email tidak valid'.tr, isError: true);
      return;
    }
    if (phone.isEmpty) {
      _showToast('Nomor telepon tidak boleh kosong'.tr, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_name', name);
      await prefs.setString('user_profile_email', email);
      await prefs.setString('user_profile_phone', phone);
      await prefs.setString('user_profile_gender', _selectedGender);
      await prefs.setString('user_profile_address', _addressController.text.trim());
      await prefs.setString('user_profile_birthdate', _birthDateController.text.trim());

      if (_profileImageUrl != null) {
        await prefs.setString('user_profile_avatar_url', _profileImageUrl!);
      }

      await EditProfileBackend.instance.updateProfile(
        fullName: name,
        email: email,
        phone: phone,
        avatarUrl: _profileImageUrl,
        gender: _selectedGender,
        address: _addressController.text.trim(),
        birthDate: _birthDateController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Data diri berhasil diperbarui!'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, {
        'name': name,
        'email': email,
        'phone': phone,
      });
    } catch (_) {
      if (!mounted) return;
      _showToast('Gagal menyimpan perubahan', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFB91C1C) : const Color(0xFF1C1C18),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPhotoOptions() {
    final isDark = ThemeService.instance.isDarkMode;
    final theme = ThemeService.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E232B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark ? Border(top: BorderSide(color: theme.border, width: 1.5)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333D4E) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ubah Foto Profil'.tr,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1C1C18),
              ),
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF28303C) : const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: theme.border) : null,
                ),
                child: Icon(Icons.camera_alt, color: isDark ? Colors.white : const Color(0xFF1C1C18), size: 20),
              ),
              title: Text(
                'Ambil Foto dari Kamera'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF28303C) : const Color(0xFFF1EEE7),
                  borderRadius: BorderRadius.circular(10),
                  border: isDark ? Border.all(color: theme.border) : null,
                ),
                child: Icon(Icons.photo_library, color: isDark ? Colors.white : const Color(0xFF1C1C18), size: 20),
              ),
              title: Text(
                'Pilih dari Galeri'.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1C1C18),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _localAvatarBytes = bytes;
        _isLoading = true;
      });

      final url = await EditProfileBackend.instance.uploadAvatar(bytes);
      if (url != null) {
        setState(() {
          _profileImageUrl = url;
        });
        // Simpan langsung ke database agar sinkron ke seluruh aplikasi
        await EditProfileBackend.instance.updateProfile(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          avatarUrl: url,
          gender: _selectedGender,
          address: _addressController.text.trim(),
          birthDate: _birthDateController.text.trim(),
        );
        _showToast('Foto profil berhasil diunggah dan disimpan!');
      } else {
        _showToast('Gagal mengunggah foto profil', isError: true);
      }
    } catch (e) {
      debugPrint('[EditProfileScreen] Error pick image: $e');
      _showToast('Terjadi kesalahan saat memilih gambar', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildFallbackAvatar(double size) {
    final name = _nameController.text.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'J';
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF114177),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.38,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService.instance, LanguageService.instance]),
      builder: (context, _) {
        final theme = ThemeService.instance;
        final isDark = theme.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? theme.bg : const Color(0xFFFCF9F2),
          body: SafeArea(
            child: Column(
              children: [
                // Header App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDark ? theme.bg : const Color(0xFFFCF9F2),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? theme.border : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : const Color(0xFFF1EEE7),
                            shape: BoxShape.circle,
                            border: isDark ? Border.all(color: theme.border) : null,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: isDark ? Colors.white : const Color(0xFF1C1C18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Edit Data Diri'.tr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1C1C18),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Photo with Camera Badge
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? theme.border : const Color(0xFFEBE6DC),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _localAvatarBytes != null
                                      ? Image.memory(
                                          _localAvatarBytes!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                          ? Image.network(
                                              _profileImageUrl!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(100),
                                            )
                                          : _buildFallbackAvatar(100),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showPhotoOptions,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFFFB923C) : const Color(0xFF1C1C18),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? theme.bg : Colors.white,
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Text(
                            'Ubah Foto Profil'.tr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFFB923C) : const Color(0xFFC05621),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Card Form Data
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? theme.card : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? theme.border : const Color(0xFFEBE6DC),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INFORMASI PENGGUNA'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF62615B),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Nama Lengkap
                              _buildFormField(
                                label: 'Nama Lengkap'.tr,
                                controller: _nameController,
                                icon: Icons.person_outline,
                                hint: 'Masukkan nama lengkap'.tr,
                                isDark: isDark,
                                theme: theme,
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildFormField(
                                label: 'Alamat Email'.tr,
                                controller: _emailController,
                                icon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                hint: 'Masukkan alamat email'.tr,
                                isDark: isDark,
                                theme: theme,
                              ),
                              const SizedBox(height: 16),

                              // Nomor Telepon
                              _buildFormField(
                                label: 'Nomor Telepon / WhatsApp'.tr,
                                controller: _phoneController,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                hint: '+62 812-xxxx-xxxx',
                                isDark: isDark,
                                theme: theme,
                              ),
                              const SizedBox(height: 16),

                              // Jenis Kelamin Selector
                              Text(
                                'Jenis Kelamin'.tr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF62615B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildGenderOption('Laki-laki', Icons.male, isDark, theme),
                                  const SizedBox(width: 12),
                                  _buildGenderOption('Perempuan', Icons.female, isDark, theme),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Tanggal Lahir (Picker Khusus Kalender)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Lahir'.tr,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF62615B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: _selectBirthDate,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? theme.surfaceField : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark ? theme.border : const Color(0xFFEBE6DC),
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 19,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF62615B),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _birthDateController.text.isNotEmpty
                                                  ? _birthDateController.text
                                                  : 'Pilih Tanggal Lahir (cth: 14 Mei 1998)',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13.5,
                                                fontWeight: _birthDateController.text.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                                                color: _birthDateController.text.isNotEmpty
                                                    ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                                                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF9E9B90)),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Pilih'.tr,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 16,
                                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Alamat
                              _buildFormField(
                                label: 'Alamat Tinggal / Domisili'.tr,
                                controller: _addressController,
                                icon: Icons.location_on_outlined,
                                hint: 'Alamat lengkap'.tr,
                                maxLines: 2,
                                isDark: isDark,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Tombol Simpan
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1C1C18),
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: isDark ? Colors.black : Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Simpan Perubahan'.tr,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool isDark,
    required ThemeService theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF62615B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? theme.surfaceField : const Color(0xFFF9F7F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? theme.border : const Color(0xFFEBE6DC),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1C1C18),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              fillColor: Colors.transparent,
              prefixIcon: Icon(
                icon,
                size: 18,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF62615B),
              ),
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF9E9B90),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, bool isDark, ThemeService theme) {
    final bool isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                : (isDark ? theme.surfaceField : const Color(0xFFF9F7F2)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF1C1C18))
                  : (isDark ? theme.border : const Color(0xFFEBE6DC)),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF62615B)),
              ),
              const SizedBox(width: 6),
              Text(
                gender.tr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF1C1C18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
