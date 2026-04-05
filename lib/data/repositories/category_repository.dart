

import 'package:Ebozor/data/model/category_model.dart';
import 'package:Ebozor/data/model/data_output.dart';
import 'package:Ebozor/utils/ApiService/api.dart';

class CategoryRepository {
  Future<DataOutput<CategoryModel>> fetchCategories({
    required int page,
    int? categoryId,
  }) async {
    try {
      Map<String, dynamic> parameters = {
        Api.page: page,
      };

      if (categoryId != null) {
        parameters[Api.categoryId] = categoryId;
      }
      Map<String, dynamic> response =
          await Api.get(url: Api.getCategoriesApi, queryParameters: parameters);

      print("FULL API RESPONSE 👉 $response");
      print("DATA 👉 ${response['data']}");
      print("LIST 👉 ${response['data']['data']}");
      print("API URL 👉 ${Api.getCategoriesApi}");

      List<CategoryModel> modelList = (response['data']['data'] as List).map(
        (e) {
          return CategoryModel.fromJson(e);
        },
      ).toList();
      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: modelList);
      // return (total: response['total'] ?? 0, modelList: modelList);
    } catch (e) {
      rethrow;
    }
  }
}
