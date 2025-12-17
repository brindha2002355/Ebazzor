import 'package:Ebozor/app/app_theme.dart';
import 'package:Ebozor/app/routes.dart';
import 'package:Ebozor/data/cubits/system/app_theme_cubit.dart';
import 'package:Ebozor/ui/screens/home/home_screen.dart';
import 'package:Ebozor/ui/theme/theme.dart';
import 'package:Ebozor/utils/constant.dart';
import 'package:Ebozor/utils/extensions/extensions.dart';
import 'package:Ebozor/utils/responsiveSize.dart';
import 'package:Ebozor/utils/ui_utils.dart';
import 'package:Ebozor/data/repositories/favourites_repository.dart';
import 'package:Ebozor/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Ebozor/data/model/item/item_model.dart';

import 'package:flutter/material.dart';

import 'package:Ebozor/utils/app_icon.dart';

import 'package:Ebozor/data/cubits/favorite/favorite_cubit.dart';
import 'package:Ebozor/data/model/home/home_screen_section.dart';

import 'package:Ebozor/ui/screens/widgets/promoted_widget.dart';
import 'package:Ebozor/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSectionsAdapter extends StatelessWidget {
  final HomeScreenSection section;

  const HomeSectionsAdapter({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    if (section.sectionData == null || section.sectionData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TitleHeader(
          title: section.title ?? "",
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.sectionWiseItemsScreen,
              arguments: {
                "title": section.title,
                "sectionId": section.sectionId,
              },
            );
          },
        ),
        GridListAdapter(
          type: ListUiType.List,
          listAxis: Axis.horizontal,
          height: 260, // 🔥 SAME AS CARD HEIGHT
          listSaperator: (_, __) => const SizedBox(width: 14),
          builder: (context, index, _) {
            final item = section.sectionData![index];
            return ItemCard(
              item: item,
              width: 160, // 🔥 SAME WIDTH FOR ALL
            );
          },
          total: section.sectionData!.length,
        ),
      ],
    );
  }
}

class ItemCard extends StatefulWidget {
  final double? width;
  final ItemModel? item;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final double likeButtonSize = 32;
  final double imageHeight = 140;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {"model": widget.item},
        );
      },
      child: Container(
        width: widget.width ?? 160,
        height: 260, // 🔥 FIXED HEIGHT
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.color.borderColor.darken(30),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: UiUtils.getImage(
                    widget.item?.image ?? "",
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                /// CONTENT
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${Constant.currencySymbol} ${widget.item?.price ?? ""}",
                      )
                          .bold()
                          .size(context.font.large)
                          .color(context.color.territoryColor),

                      const SizedBox(height: 4),

                      Text(widget.item?.name ?? "")
                          .firstUpperCaseWidget()
                          .setMaxLines(lines: 1)
                          .size(context.font.large),

                      const SizedBox(height: 6),

                      if ((widget.item?.address ?? "").isNotEmpty)
                        Row(
                          children: [
                            UiUtils.getSvg(
                              AppIcons.location,
                              width: 10,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(widget.item?.address ?? "")
                                  .size(context.font.smaller)
                                  .setMaxLines(lines: 1)
                                  .color(
                                context.color.textDefaultColor
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            /// FAVORITE BUTTON
            _favButton(),
          ],
        ),
      ),
    );
  }

  Widget _favButton() {
    bool isLike =
    context.read<FavoriteCubit>().isItemFavorite(widget.item!.id!);

    return BlocProvider(
      create: (_) => UpdateFavoriteCubit(FavoriteRepository()),
      child: BlocConsumer<FavoriteCubit, FavoriteState>(
        bloc: context.read<FavoriteCubit>(),
        listener: (_, __) {
          isLike = context
              .read<FavoriteCubit>()
              .isItemFavorite(widget.item!.id!);
        },
        builder: (context, _) {
          return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
            listener: (context, state) {
              if (state is UpdateFavoriteSuccess) {
                if (state.wasProcess) {
                  context
                      .read<FavoriteCubit>()
                      .addFavoriteitem(state.item);
                } else {
                  context
                      .read<FavoriteCubit>()
                      .removeFavoriteItem(state.item);
                }
              }
            },
            builder: (context, state) {
              return Positioned(
                top: imageHeight - (likeButtonSize / 2),
                right: 12,
                child: InkWell(
                  onTap: () {
                    UiUtils.checkUser(
                      context: context,
                      onNotGuest: () {
                        context
                            .read<UpdateFavoriteCubit>()
                            .setFavoriteItem(
                          item: widget.item!,
                          type: isLike ? 0 : 1,
                        );
                      },
                    );
                  },
                  child: Container(
                    width: likeButtonSize,
                    height: likeButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.color.secondaryColor,
                      boxShadow:
                      context.watch<AppThemeCubit>().state.appTheme ==
                          AppTheme.dark
                          ? null
                          : [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: state is UpdateFavoriteInProgress
                        ? Center(child: UiUtils.progress())
                        : UiUtils.getSvg(
                      isLike
                          ? AppIcons.like_fill
                          : AppIcons.like,
                      width: 22,
                      height: 22,
                      color: context.color.territoryColor,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TitleHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool hideSeeAll;

  const TitleHeader({
    super.key,
    required this.title,
    required this.onTap,
    this.hideSeeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 18,
        bottom: 12,
        start: sidePadding,
        end: sidePadding,
      ),
      child: Row(
        children: [
          /// TITLE
          Expanded(
            child: Text(title)
                .size(context.font.large)
                .bold(weight: FontWeight.w600)
                .setMaxLines(lines: 1),
          ),

          /// SEE ALL
          if (!hideSeeAll)
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text("seeAll".translate(context))
                    .size(context.font.smaller + 3)
                    .color(context.color.deactivateColor),
              ),
            ),
        ],
      ),
    );
  }
}


