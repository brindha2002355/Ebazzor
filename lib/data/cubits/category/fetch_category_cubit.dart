// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:Ebozor/data/model/category_model.dart';
import 'package:Ebozor/data/model/data_output.dart';
import 'package:Ebozor/data/repositories/category_repository.dart';
import 'package:Ebozor/utils/helper_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class FetchCategoryState {}

class FetchCategoryInitial extends FetchCategoryState {}

class FetchCategoryInProgress extends FetchCategoryState {}



//categories models showing model it belongs to categories model

class FetchCategoryFailure extends FetchCategoryState {
  final String errorMessage;

  FetchCategoryFailure(this.errorMessage);
}
//
// class FetchCategoryCubit extends Cubit<FetchCategoryState>{
//   FetchCategoryCubit() : super(FetchCategoryInitial());
//
//   final CategoryRepository _categoryRepository = CategoryRepository();
//
//   Future<void> fetchCategories(
//       {bool? forceRefresh, bool? loadWithoutDelay}) async
//   {
//     try {
//       emit(FetchCategoryInProgress());
//
//       DataOutput<CategoryModel> categories =
//       await _categoryRepository.fetchCategories(page: 1);
//
//
//       emit(FetchCategorySuccess(
//           total: categories.total,
//           categories: categories.modelList,
//           page: 1,
//           hasError: false,
//           isLoadingMore: false));
//     } catch (e) {
//       emit(FetchCategoryFailure(e.toString()));
//     }
//   }
//
//   List<CategoryModel> getCategories() {
//     if (state is FetchCategorySuccess) {
//       return (state as FetchCategorySuccess).categories;
//     }
//
//     return <CategoryModel>[];
//   }
//
//   Future<void> fetchCategoriesMore() async {
//     try {
//       if (state is FetchCategorySuccess) {
//         if ((state as FetchCategorySuccess).isLoadingMore) {
//           return;
//         }
//         emit((state as FetchCategorySuccess).copyWith(isLoadingMore: true));
//         DataOutput<CategoryModel> result =
//         await _categoryRepository.fetchCategories(
//           page: (state as FetchCategorySuccess).page + 1,
//         );
//
//         FetchCategorySuccess categoryState = (state as FetchCategorySuccess);
//         categoryState.categories.addAll(result.modelList);
//
//         List<String> list =
//         categoryState.categories.map((e) => e.url!).toList();
//         await HelperUtils.precacheSVG(list);
//
//         emit(FetchCategorySuccess(
//             isLoadingMore: false,
//             hasError: false,
//             categories: categoryState.categories,
//             page: (state as FetchCategorySuccess).page + 1,
//             total: result.total));
//       }
//     } catch (e) {
//       emit((state as FetchCategorySuccess)
//           .copyWith(isLoadingMore: false, hasError: true));
//     }
//   }
//
//   bool hasMoreData() {
//     if (state is FetchCategorySuccess) {
//       return (state as FetchCategorySuccess).categories.length <
//           (state as FetchCategorySuccess).total;
//     }
//     return false;
//   }
// }
class FetchCategoryCubit extends Cubit<FetchCategoryState> {
  FetchCategoryCubit() : super(FetchCategoryInitial());

  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<void> fetchCategories() async {
    try {
      print("🚀 FETCH STARTED");

      emit(FetchCategoryInProgress());

      DataOutput<CategoryModel> categories =
      await _categoryRepository.fetchCategories(page: 1);

      print("✅ API SUCCESS");
      print("📊 TOTAL: ${categories.total}");
      print("📦 LIST LENGTH: ${categories.modelList.length}");

      for (var e in categories.modelList) {
        print("👉 CATEGORY: ${e.name}");
        print("👉 IMAGE: ${e.url}");
      }

      emit(FetchCategorySuccess(
        total: categories.total,
        categories: categories.modelList,
        page: 1,
        hasError: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      print("❌ ERROR IN fetchCategories: $e");
      emit(FetchCategoryFailure(e.toString()));
    }
  }

  Future<void> fetchCategoriesMore() async {
    try {
      print("🔄 LOAD MORE TRIGGERED");

      if (state is FetchCategorySuccess) {
        final currentState = state as FetchCategorySuccess;

        if (currentState.isLoadingMore) {
          print("⛔ Already loading");
          return;
        }

        emit(currentState.copyWith(isLoadingMore: true));

        DataOutput<CategoryModel> result =
        await _categoryRepository.fetchCategories(
          page: currentState.page + 1,
        );

        print("✅ LOAD MORE SUCCESS");
        print("📦 NEW ITEMS: ${result.modelList.length}");

        final updatedList = [
          ...currentState.categories,
          ...result.modelList,
        ];

        print("📊 TOTAL LIST NOW: ${updatedList.length}");

        /// 🔥 DEBUG SVG URLS
        List<String> list =
        updatedList.map((e) => e.url ?? "").toList();

        for (var url in list) {
          print("🖼️ SVG URL: $url");
        }

        /// TRY PRECACHE
        try {
          await HelperUtils.precacheSVG(list);
          print("✅ SVG PRECACHE DONE");
        } catch (e) {
          print("❌ SVG PRECACHE ERROR: $e");
        }

        emit(FetchCategorySuccess(
          categories: updatedList,
          page: currentState.page + 1,
          total: result.total,
          isLoadingMore: false,
          hasError: false,
        ));
      }
    } catch (e) {
      print("❌ ERROR IN fetchCategoriesMore: $e");

      emit((state as FetchCategorySuccess).copyWith(
        isLoadingMore: false,
        hasError: true,
      ));
    }
  }

  bool hasMoreData() {
    if (state is FetchCategorySuccess) {
      final current = state as FetchCategorySuccess;

      print("🔍 HAS MORE CHECK");
      print("CURRENT LENGTH: ${current.categories.length}");
      print("TOTAL: ${current.total}");

      return current.categories.length < current.total;
    }
    return false;
  }
}class FetchCategorySuccess extends FetchCategoryState {
  final int total;
  final int page;
  final bool isLoadingMore;
  final bool hasError;
  final List<CategoryModel> categories;

  FetchCategorySuccess({
    required this.total,
    required this.page,
    required this.isLoadingMore,
    required this.hasError,
    required this.categories,
  });

  FetchCategorySuccess copyWith({
    int? total,
    int? page,
    bool? isLoadingMore,
    bool? hasError,
    List<CategoryModel>? categories,
  }) {
    return FetchCategorySuccess(
      total: total ?? this.total,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'total': total,
      ' page': page,
      'isLoadingMore': isLoadingMore,
      'hasError': hasError,
      'categories': categories.map((x) => x.toJson()).toList(),
    };
  }

  factory FetchCategorySuccess.fromMap(Map<String, dynamic> map) {
    return FetchCategorySuccess(
      total: map['total'] as int,
      page: map[' page'] as int,
      isLoadingMore: map['isLoadingMore'] as bool,
      hasError: map['hasError'] as bool,
      categories: List<CategoryModel>.from(
        (map['categories']).map<CategoryModel>(
              (x) => CategoryModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory FetchCategorySuccess.fromJson(String source) =>
      FetchCategorySuccess.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FetchCategorySuccess(total: $total,  page: $page, isLoadingMore: $isLoadingMore, hasError: $hasError, categories: $categories)';
  }
}
