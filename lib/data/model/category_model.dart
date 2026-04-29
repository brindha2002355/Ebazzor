// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Ebozor/utils/ApiService/api.dart';

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
}

class CategoryModel {
  final int? id;
  final String? name;
  final String? url;
  final String? slug;
  final List<CategoryModel>? children;
  final String? description;

  //final String translatedName;
  final int? subcategoriesCount;

  CategoryModel({
     this.id,
     this.name,
     this.url,
     this.description,
     this.children,
    this.subcategoriesCount, this.slug,
    //required this.translatedName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      List<dynamic> childData = json['subcategories'] ?? [];
      List<CategoryModel> children =
          childData.map((child) => CategoryModel.fromJson(child)).toList();

      return CategoryModel(
          id: json['id'],
          //name: json['name'],
        //  name: json['translated_name'],
          name: (json['translated_name'] != null && json['translated_name'] != "")
              ? json['translated_name']
              : json['name'],
          url: (json['image'] != null && json['image'] != "")
              ? json['image']
              : null,
          slug: json['slug'],
         // url: json['image'],
          subcategoriesCount: json['subcategories_count']??0,
          children: children,
          description: json['description'] ?? "");
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      //'name': name,
      'translated_name': name,
      'image': url,
      'subcategories_count': subcategoriesCount,
      "description": description,
      'subcategories': children!.map((child) => child.toJson()).toList(),
    };
    return data;
  }

  @override
  String toString() {
    return 'CategoryModel( id: $id, translated_name:$name, url: $url, descrtiption:$description, children: $children,subcategories_count:$subcategoriesCount)';
  }
}
// class FilterCategory {
//   final int id;
//   final String name;
//   final String slug;
//   final List<FilterSubCategory> children;
//   final List<FilterItem> filters;
//
//   FilterCategory({
//     required this.id,
//     required this.name,
//     required this.slug,
//     required this.children,
//     required this.filters,
//   });
//
//   factory FilterCategory.fromJson(Map<String, dynamic> json) {
//     return FilterCategory(
//       id: json['category_id'],
//       name: json['name'],
//       slug: json['slug'],
//       children: (json['children'] as List)
//           .map((e) => FilterSubCategory.fromJson(e))
//           .toList(),
//       filters: (json['filters'] as List)
//           .map((e) => FilterItem.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class FilterItem {
//   final String name;
//   final String type;
//   final List<String> values;
//   final bool multiSelect;
//
//   FilterItem({
//     required this.name,
//     required this.type,
//     required this.values,
//     required this.multiSelect,
//   });
//
//   factory FilterItem.fromJson(Map<String, dynamic> json) {
//     return FilterItem(
//       name: json['name'],
//       type: json['type'],
//       values: List<String>.from(json['values'] ?? []),
//       multiSelect: json['multiselect'] == true,
//     );
//   }
// }
//
// class FilterSubCategory {
//   final int id;
//   final String name;
//   final String slug;
//
//   FilterSubCategory({
//     required this.id,
//     required this.name,
//     required this.slug,
//   });
//
//   factory FilterSubCategory.fromJson(Map<String, dynamic> json) {
//     return FilterSubCategory(
//       id: json['category_id'],
//       name: json['name'],
//       slug: json['slug'],
//     );
//   }
// }

class FilterCategory {
  final int? id;        // ✅ nullable
  final String? name;   // ✅ nullable
  final String? slug;   // ✅ nullable
  final List<FilterSubCategory> children;
  final List<FilterItem> filters;

  FilterCategory({
    this.id,
    this.name,
    this.slug,
    required this.children,
    required this.filters,
  });

  factory FilterCategory.fromJson(Map<String, dynamic> json) {
    return FilterCategory(
      id: json['category_id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      children: (json['children'] as List? ?? [])
          .map((e) => FilterSubCategory.fromJson(e))
          .toList(),
      filters: (json['filters'] as List? ?? [])
          .map((e) => FilterItem.fromJson(e))
          .toList(),
    );
  }
}

class FilterSubCategory {
  final int? id;       // ✅ nullable
  final String? name;  // ✅ nullable
  final String? slug;  // ✅ nullable

  FilterSubCategory({
    this.id,
    this.name,
    this.slug,
  });

  factory FilterSubCategory.fromJson(Map<String, dynamic> json) {
    return FilterSubCategory(
      id: json['category_id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
    );
  }
}

// class FilterItem {
//   final String? name;        // ✅ nullable
//   final String? type;        // ✅ nullable
//   final List<String> values;
//   final bool multiSelect;
//
//   FilterItem({
//     this.name,
//     this.type,
//     required this.values,
//     required this.multiSelect,
//   });
//
//   factory FilterItem.fromJson(Map<String, dynamic> json) {
//     return FilterItem(
//       name: json['name'] as String?,
//       type: json['type'] as String?,
//       values: List<String>.from(json['values'] ?? []),
//       multiSelect: json['multiselect'] == true,
//     );
//   }
// }

class FilterItem {
  final String? name;
  final String? type;
  final List<String> values;
  final bool multiSelect;
  final String? placeholder; // ✅ add this

  FilterItem({
    this.name,
    this.type,
    required this.values,
    required this.multiSelect,
    this.placeholder,
  });

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(
      name: json['name'] as String?,
      type: json['type'] as String?,
      values: List<String>.from(json['values'] ?? []),
      multiSelect: json['multiselect'] == true,
      placeholder: json['placeholder'] as String?, // ✅ add this
    );
  }
}