import 'package:flutter/material.dart';

enum SidebarItem { home, search, library, favorites }

class Sidebar extends StatelessWidget {
  final SidebarItem activeItem;
  final ValueChanged<SidebarItem> onItemSelected;
  final bool isCollapsed;

  const Sidebar({
    super.key,
    this.activeItem = SidebarItem.home,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: isCollapsed ? 72 : 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withAlpha(12),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withAlpha(180)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'YTune',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          const SizedBox(height: 32),
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: activeItem == SidebarItem.home,
            isCollapsed: isCollapsed,
            onTap: () => onItemSelected(SidebarItem.home),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Search',
            isActive: activeItem == SidebarItem.search,
            isCollapsed: isCollapsed,
            onTap: () => onItemSelected(SidebarItem.search),
          ),
          _NavItem(
            icon: Icons.library_music_rounded,
            label: 'Library',
            isActive: activeItem == SidebarItem.library,
            isCollapsed: isCollapsed,
            onTap: () => onItemSelected(SidebarItem.library),
          ),
          _NavItem(
            icon: Icons.favorite_rounded,
            label: 'Favorites',
            isActive: activeItem == SidebarItem.favorites,
            isCollapsed: isCollapsed,
            onTap: () => onItemSelected(SidebarItem.favorites),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withAlpha(12)),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(Icons.settings_rounded,
                    color: Colors.grey[600], size: 20),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primary.withAlpha(20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive ? colorScheme.primary : Colors.grey[500],
                  size: 22,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color:
                          isActive ? colorScheme.primary : Colors.grey[400],
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
