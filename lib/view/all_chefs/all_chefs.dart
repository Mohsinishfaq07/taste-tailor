// ignore_for_file: must_be_immutable, unused_element, avoid_types_as_parameter_names

import 'package:taste_tailor/model/chief_detail_model.dart';
import 'package:taste_tailor/utils/chef_city_extractor.dart';
import 'package:taste_tailor/view/dashboard/User_dashboard_request_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tailor/extensions/context_tri_l10n.dart';
import 'package:taste_tailor/l10n/app_localizations_en.dart';
import 'package:taste_tailor/l10n/app_localizations_ur.dart';
import 'package:taste_tailor/global_custom_widgets/custom_app_bar.dart';
import 'package:taste_tailor/provider/locale_notifier.dart';
import 'package:taste_tailor/utils/unfocus_on_route_cover_mixin.dart';

class AllChefs extends StatefulWidget {
  const AllChefs({super.key, this.userid});
  static const String tag = "AllChefs";
  final String? userid;

  @override
  State<AllChefs> createState() => _AllChefsState();
}

class _AllChefsState extends State<AllChefs>
    with SingleTickerProviderStateMixin, UnfocusOnRouteCoverMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  /// `null` = show all cities; otherwise normalized key from [ChefCityExtractor.normalizeKey].
  String? _cityFilterKey;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(() => setState(() {}));
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<ChiefDetailModel> _filterChefsByName(List<ChiefDetailModel> chefs) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return chefs;
    return chefs
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  List<ChiefDetailModel> _filterChefsByCity(List<ChiefDetailModel> chefs) {
    if (_cityFilterKey == null) return chefs;
    return chefs.where((c) {
      final display = c.effectiveCityDisplay.trim();
      if (display.isEmpty) return false;
      return ChefCityExtractor.normalizeKey(display) == _cityFilterKey;
    }).toList();
  }

  /// Unique cities (normalized key → display label) for filter chips.
  Map<String, String> _cityKeyToLabel(List<ChiefDetailModel> chefs) {
    final map = <String, String>{};
    for (final c in chefs) {
      final display = c.effectiveCityDisplay.trim();
      if (display.isEmpty) continue;
      final k = ChefCityExtractor.normalizeKey(display);
      map.putIfAbsent(k, () => display);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  Widget _buildLocationChips(Map<String, String> cityKeyToLabel) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: Text(
                context.tri((l) => l.allLocations),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: _cityFilterKey == null,
              onSelected: (_) => setState(() => _cityFilterKey = null),
              selectedColor: const Color(0xFFFFE0B2),
              checkmarkColor: const Color(0xFFEF6C00),
              side: const BorderSide(color: Color(0xFFFFA726)),
            ),
            SizedBox(width: 8.w),
            ...cityKeyToLabel.entries.map((e) {
              final selected = _cityFilterKey == e.key;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _cityFilterKey = selected ? null : e.key;
                  }),
                  selectedColor: const Color(0xFFFFE0B2),
                  checkmarkColor: const Color(0xFFEF6C00),
                  side: const BorderSide(color: Color(0xFFFFA726)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFFFA726), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9800).withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4E342E),
          ),
          decoration: InputDecoration(
            hintText:
                '${context.tri((l) => l.chefsSearchPrefixHint)}${context.tri((l) => l.searchChefByName)}',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon:
                Icon(Icons.search_rounded, color: Colors.deepOrange.shade400),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.deepOrange.shade400,
                      size: 22,
                    ),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            isDense: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: context.tri((l) => l.allChefsTitle),
        showBackButton: true,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('allusers')
          .where('role', isEqualTo: 'chief')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        final chefs = snapshot.data!.docs
            .map((doc) {
              final m = Map<String, dynamic>.from(
                doc.data() as Map<String, dynamic>,
              );
              final mergedId = '${m['userId'] ?? m['id'] ?? m['uid'] ?? ''}'.trim();
              if (mergedId.isEmpty && doc.id.isNotEmpty) {
                m['userId'] = doc.id;
              }
              return ChiefDetailModel.fromJson(m);
            })
            .where((chef) => chef.userId.isNotEmpty && chef.name.isNotEmpty)
            .toList();

        if (chefs.isEmpty) {
          return _buildEmptyState(context);
        }

        final cityKeyToLabel = _cityKeyToLabel(chefs);
        final byCity = _filterChefsByCity(chefs);
        if (byCity.isEmpty && _cityFilterKey != null) {
          final areaName = cityKeyToLabel[_cityFilterKey] ?? _cityFilterKey;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLocationChips(cityKeyToLabel),
              Expanded(
                child: _buildNoChefsInSelectedCity(context, areaName ?? ''),
              ),
            ],
          );
        }

        final filtered = _filterChefsByName(byCity);
        if (filtered.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLocationChips(cityKeyToLabel),
              Expanded(child: _buildNoSearchResults(context)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLocationChips(cityKeyToLabel),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 12.h),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return ChefCard(chef: filtered[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoChefsInSelectedCity(BuildContext context, String areaLabel) {
    final area = areaLabel.trim().isEmpty ? '—' : areaLabel.trim();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              color: const Color(0xFFFFB74D),
              size: 56.sp,
            ),
            SizedBox(height: 14.h),
            Text(
              context.tri((l) => l.noChefsInCity(area)),
              style: TextStyle(
                color: const Color(0xFF6D4C41),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              context.tri((l) => l.chooseAllLocationsOrCity),
              style: TextStyle(
                color: const Color(0xFF8D6E63),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    final q = _searchController.text.trim();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.manage_search_rounded,
              color: const Color(0xFFFFB74D),
              size: 56.sp,
            ),
            SizedBox(height: 14.h),
            Text(
              context.tri((l) => l.noChefMatchSearch(q)),
              style: TextStyle(
                color: const Color(0xFF6D4C41),
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              context.tri((l) => _cityFilterKey != null
                  ? l.tryWidenLocationFilter
                  : l.tryAnotherChefName),
              style: TextStyle(
                color: const Color(0xFF8D6E63),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFB74D)),
        ),
        child: const CircularProgressIndicator(
          color: Color(0xFFFF9800),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFE57373),
            size: 60.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tri((l) => l.errorWithMessage(error)),
            style: TextStyle(
              color: const Color(0xFF6D4C41),
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            color: const Color(0xFFFFB74D),
            size: 60.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            context.tri((l) => l.noChefsAvailable),
            style: TextStyle(
              color: const Color(0xFF6D4C41),
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ChefCard extends StatelessWidget {
  final ChiefDetailModel chef;

  const ChefCard({super.key, required this.chef});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFFFCC80)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFB8C00), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Column(
          children: [
            _buildHeader(context),
            _buildBody(context),
            _buildBookChefBar(context),
            _buildRatingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBookChefBar(BuildContext context) {
    if (chef.userId.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            final u = FirebaseAuth.instance.currentUser;
            if (u == null) {
              Fluttertoast.showToast(
                msg: LocaleNotifier.toast(
                  AppLocalizationsEn().signInToBookChef,
                  AppLocalizationsUr().signInToBookChef,
                ),
              );
              return;
            }
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => UserDashboardRequestForm(
                  preferredChefId: chef.userId.trim(),
                  preferredChefName: chef.name.trim(),
                ),
              ),
            );
          },
          icon: Icon(Icons.calendar_month_rounded, size: 20.sp),
          label: Text(
            context.tri((l) => l.bookThisChef),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE65100),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 10.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          _buildProfileImage(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chef.name,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4E342E),
                  ),
                ),
                SizedBox(height: 5.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: [
                    _chip(context.tri((l) => l.chefCardChefChip)),
                    if (chef.effectiveCityDisplay.trim().isNotEmpty)
                      _chip('📍 ${chef.effectiveCityDisplay.trim()}'),
                    if (chef.specialties.trim().isNotEmpty)
                      _chip('🍽 ${chef.specialties}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 62.w,
      height: 62.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(color: const Color(0xFFFFA726), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFB8C00).withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: chef.image.isNotEmpty
            ? Image.network(
                chef.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.person, size: 31.sp, color: Colors.brown),
              )
            : Icon(Icons.person, size: 31.sp, color: Colors.brown),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Column(
        children: [
          _buildInfoRow(
              context, context.tri((l) => l.chefCardExperienceRow), chef.workExperience),
          _buildInfoRow(
              context, context.tri((l) => l.chefCardContactRow), chef.number),
          _buildInfoRow(
              context, context.tri((l) => l.chefCardAddressRow), chef.address),
          _buildInfoRow(
              context, context.tri((l) => l.chefCardEmailRow), chef.email),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final na = context.tri((l) => l.notAvailableAbbrev);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 7.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 12.5.sp,
            color: const Color(0xFF5D4037),
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: value.trim().isEmpty ? na : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsSection(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getChefRatingsAndComments(chef.userId),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final ratings = snapshot.data ?? [];
        if (ratings.isEmpty) {
          return _buildNoRatings(ctx);
        }

        final averageRating = _calculateAverageRating(ratings);
        return _buildRatingsContent(ctx, averageRating, ratings);
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _getChefRatingsAndComments(String chefId) {
    return FirebaseFirestore.instance
        .collection('chef_ratings')
        .where('chefId', isEqualTo: chefId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  double _calculateAverageRating(List<Map<String, dynamic>> ratings) {
    final values = ratings
        .map((rating) => (rating['rating'] as num?)?.toDouble() ?? 0.0)
        .toList();
    if (values.isEmpty) return 0.0;
    return values.fold(0.0, (a, b) => a + b) / values.length;
  }

  Widget _buildNoRatings(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Text(
        context.tri((l) => l.chefCardNoRatings),
        style: TextStyle(
          fontSize: 12.5.sp,
          color: const Color(0xFF6D4C41),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRatingsContent(BuildContext context, double averageRating,
      List<Map<String, dynamic>> ratings) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8.w),
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4E342E),
                ),
              ),
              Text(
                context.tri((l) => l.chefCardReviewsCount(ratings.length)),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6D4C41),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (ratings.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...ratings
                .take(3)
                .map((rating) => _buildReviewItem(context, rating)),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, Map<String, dynamic> rating) {
    final reviewValue = rating['review']?.toString() ?? '';
    final ratingValue = (rating['rating'] as num?)?.toDouble() ?? 0.0;
    final noFeedback =
        '"${context.tri((l) => l.reviewNoWrittenFeedback)}"';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Text(
            '${ratingValue.toStringAsFixed(1)}★',
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFFEF6C00),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              reviewValue.isEmpty ? noFeedback : '"$reviewValue"',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6D4C41),
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFA726)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }
}
