import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final String? initialText;
  final bool isMobile;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.initialText,
    this.isMobile = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null) {
      _controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      widget.onSearch(trimmed);
    }
  }

  void _onClear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      onSubmitted: _onSubmitted,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: Colors.white, fontSize: widget.isMobile ? 14 : 16),
      decoration: InputDecoration(
        hintText: 'Search for songs, artists...',
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: widget.isMobile ? 14 : 16),
        prefixIcon:
            Icon(Icons.search_rounded, color: Colors.grey[400], size: widget.isMobile ? 20 : 24),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon:
                    Icon(Icons.clear_rounded, color: Colors.grey[400], size: widget.isMobile ? 18 : 20),
                onPressed: _onClear,
              )
            : null,
        filled: true,
        fillColor: colorScheme.surface.withAlpha(220),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(180),
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 16 : 20,
          vertical: widget.isMobile ? 12 : 16,
        ),
      ),
    );
  }
}
