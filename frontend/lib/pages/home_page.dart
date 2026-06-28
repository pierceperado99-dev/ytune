import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/music_bloc.dart';
import '../bloc/music_event.dart';
import '../bloc/music_state.dart';
import '../widgets/music_card.dart';
import '../widgets/music_player_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sidebar.dart';

const _navItems = [
  (SidebarItem.search, Icons.search_rounded, 'Search'),
  (SidebarItem.library, Icons.library_music_rounded, 'Library'),
  (SidebarItem.favorites, Icons.favorite_rounded, 'Favorites'),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MusicBloc>(
      create: (_) => GetIt.instance<MusicBloc>(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  SidebarItem _activeSidebar = SidebarItem.search;
  bool _sidebarCollapsed = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 900;
    final isDesktop = width >= 900;

    if (isTablet) _sidebarCollapsed = true;
    if (isDesktop) _sidebarCollapsed = false;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (!isMobile)
                  Sidebar(
                    activeItem: _activeSidebar,
                    onItemSelected: (item) {
                      setState(() => _activeSidebar = item);
                    },
                    isCollapsed: _sidebarCollapsed,
                  ),
                Expanded(
                  child: _MainContent(
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<MusicBloc, MusicState>(
            buildWhen: (prev, current) =>
                prev.currentSong?.id != current.currentSong?.id ||
                prev.isPlaying != current.isPlaying,
            builder: (context, state) {
              if (state.currentSong != null) {
                return MusicPlayerBar(isMobile: isMobile);
              }
              if (!isMobile) {
                return Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    border: Border(
                      top: BorderSide(color: Colors.white.withAlpha(12)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Select a song to start playing',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  Widget _buildBottomNav() {
    final index = _navItems.indexWhere((e) => e.$1 == _activeSidebar);
    final clamped = index >= 0 ? index : 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(12)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: clamped,
        onTap: (i) => setState(() => _activeSidebar = _navItems[i].$1),
        backgroundColor: const Color(0xFF141414),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        items: _navItems
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e.$2),
                  label: e.$3,
                ))
            .toList(),
      ),
    );
  }
}

class _MainContent extends StatefulWidget {
  final bool isMobile;

  const _MainContent({required this.isMobile});

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<MusicBloc>().add(SearchMusicRequested(query));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: widget.isMobile ? 12 : 24,
        right: widget.isMobile ? 12 : 24,
        top: widget.isMobile ? 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: widget.isMobile ? 4 : 8),
          Text(
            'Find your favorite music',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          SizedBox(height: widget.isMobile ? 14 : 20),
          SearchBarWidget(
            onSearch: _onSearch,
            initialText: _searchController.text,
            isMobile: widget.isMobile,
          ),
          SizedBox(height: widget.isMobile ? 16 : 24),
          Expanded(
            child: BlocConsumer<MusicBloc, MusicState>(
              buildWhen: (prev, current) =>
                  prev.searchResults != current.searchResults ||
                  prev.error != current.error ||
                  (prev.isLoading != current.isLoading &&
                      prev.currentSong?.id == current.currentSong?.id) ||
                  prev.hasSearched != current.hasSearched ||
                  prev.currentSong?.id != current.currentSong?.id ||
                  prev.isPlaying != current.isPlaying,
              listener: (context, state) {
                if (state.error != null && state.currentSong == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.searchResults.isEmpty && state.isLoading) {
                  return _buildLoadingState();
                }

                if (state.searchResults.isEmpty && !state.hasSearched) {
                  return _buildEmptyState(colorScheme);
                }

                if (state.searchResults.isEmpty && state.hasSearched) {
                  return _buildNoResultsState(colorScheme);
                }

                return _buildResultsList(context, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.primary.withAlpha(150),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Discover new music',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for songs, artists, or albums',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final isMobile = widget.isMobile;
    final thumbSize = isMobile ? 44.0 : 52.0;
    final titleWidth = isMobile ? 150.0 : 200.0;

    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
          child: Row(
            children: [
              Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: titleWidth,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: titleWidth * 0.7,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResultsState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.music_off_rounded,
              color: Colors.grey[600],
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No results found',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, MusicState state) {
    final currentSongId = state.currentSong?.id;

    return RefreshIndicator(
      onRefresh: () async {
        final query = _searchController.text.trim();
        if (query.isNotEmpty) {
          context.read<MusicBloc>().add(SearchMusicRequested(query));
        }
      },
      child: ListView.builder(
        itemCount: state.searchResults.length,
        itemBuilder: (context, index) {
          final music = state.searchResults[index];
          return MusicCard(
            music: music,
            isMobile: widget.isMobile,
            isActive: currentSongId == music.id && state.isPlaying,
            onPlay: () {
              if (currentSongId == music.id) {
                final bloc = context.read<MusicBloc>();
                if (state.isPlaying) {
                  bloc.add(const PauseMusicRequested());
                } else {
                  bloc.add(const ResumeMusicRequested());
                }
              } else {
                context
                    .read<MusicBloc>()
                    .add(PlayMusicRequested(music));
              }
            },
          );
        },
      ),
    );
  }
}
