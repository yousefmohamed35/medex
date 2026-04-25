import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design/app_colors.dart';
import '../../services/community_service.dart';
import '../../services/upload_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isPosting = false;
  String _selectedVisibility = 'public';
  File? _selectedImage;
  File? _selectedVideo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null && _selectedVideo == null) {
      return;
    }

    setState(() => _isPosting = true);

    try {
      final media = <String>[];
      if (_selectedImage != null) {
        final imageUrl =
            await UploadService.instance.uploadImage(_selectedImage!);
        media.add(imageUrl);
      }
      if (_selectedVideo != null) {
        final videoUrl =
            await UploadService.instance.uploadVideo(_selectedVideo!);
        media.add(videoUrl);
      }

      await CommunityService.instance.createPost(
        content: content,
        media: media,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isPosting = false);
      return;
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نشر المنشور بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final hasContent = _contentController.text.trim().isNotEmpty;
    final canPost =
        hasContent || _selectedImage != null || _selectedVideo != null;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            isAr ? 'إنشاء منشور' : 'Create Post',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.foreground),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: canPost && !_isPosting ? _publishPost : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isAr ? 'نشر' : 'Post',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.person,
                              color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أنا',
                                style: GoogleFonts.cairo(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            GestureDetector(
                              onTap: _showVisibilityPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _selectedVisibility == 'public'
                                          ? Icons.public
                                          : Icons.people,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _selectedVisibility == 'public'
                                          ? (isAr ? 'عام' : 'Public')
                                          : (isAr ? 'المتابعين' : 'Followers'),
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(Icons.arrow_drop_down,
                                        size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 8,
                      style: GoogleFonts.cairo(fontSize: 18, height: 1.6),
                      decoration: InputDecoration(
                        hintText: isAr
                            ? 'ماذا يدور في ذهنك؟'
                            : "What's on your mind?",
                        hintStyle: GoogleFonts.cairo(
                            fontSize: 18, color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_selectedImage != null || _selectedVideo != null) ...[
                      const SizedBox(height: 16),
                      _buildSelectedMedia(isAr),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomToolbar(isAr),
          ],
        ),
      ),
    );
  }

  void _showVisibilityPicker() {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(isAr ? 'من يمكنه رؤية منشورك؟' : 'Who can see your post?',
                style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _VisibilityOption(
              icon: Icons.public,
              title: isAr ? 'عام' : 'Public',
              subtitle: isAr
                  ? 'الجميع يمكنه رؤية المنشور'
                  : 'Everyone can see your post',
              isSelected: _selectedVisibility == 'public',
              onTap: () {
                setState(() => _selectedVisibility = 'public');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            _VisibilityOption(
              icon: Icons.people,
              title: isAr ? 'المتابعين فقط' : 'Followers only',
              subtitle: isAr
                  ? 'المتابعين فقط يمكنهم رؤية المنشور'
                  : 'Only followers can see your post',
              isSelected: _selectedVisibility == 'followers',
              onTap: () {
                setState(() => _selectedVisibility = 'followers');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(bool isAr) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolbarItem(
              icon: Icons.image_rounded,
              label: isAr ? 'صورة' : 'Photo',
              color: Colors.green,
              onTap: _pickImage),
          _ToolbarItem(
              icon: Icons.videocam_rounded,
              label: isAr ? 'فيديو' : 'Video',
              color: AppColors.primary,
              onTap: _pickVideo),
          _ToolbarItem(
              icon: Icons.gif_box_rounded,
              label: 'GIF',
              color: Colors.purple,
              onTap: () {}),
          _ToolbarItem(
              icon: Icons.location_on_rounded,
              label: isAr ? 'موقع' : 'Location',
              color: Colors.orange,
              onTap: () {}),
          _ToolbarItem(
              icon: Icons.person_add_rounded,
              label: isAr ? 'إشارة' : 'Tag',
              color: Colors.blue,
              onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSelectedMedia(bool isAr) {
    return Column(
      children: [
        if (_selectedImage != null)
          _MediaAttachmentTile(
            icon: Icons.image_rounded,
            title: isAr ? 'تم اختيار صورة' : 'Image selected',
            subtitle: _selectedImage!.path.split(Platform.pathSeparator).last,
            onRemove: () => setState(() => _selectedImage = null),
          ),
        if (_selectedVideo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _MediaAttachmentTile(
              icon: Icons.videocam_rounded,
              title: isAr ? 'تم اختيار فيديو' : 'Video selected',
              subtitle: _selectedVideo!.path.split(Platform.pathSeparator).last,
              onRemove: () => setState(() => _selectedVideo = null),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;
      setState(() => _selectedImage = File(result.files.single.path!));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to select image: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;
      setState(() => _selectedVideo = File(result.files.single.path!));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to select video: $e', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (isSelected ? AppColors.primary : Colors.grey)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ToolbarItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MediaAttachmentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  const _MediaAttachmentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.cairo(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
