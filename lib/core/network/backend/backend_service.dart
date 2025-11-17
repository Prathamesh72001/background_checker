abstract class BackendService {
  Future<T?> getData<T>(String path);
  Future<Map<String, dynamic>?> getCollection(String path);
  Future<bool> setData(String path, Map<String, dynamic> data);
  Future<bool> updateData(String path, Map<String, dynamic> data);
  Future<bool> deleteData(String path);
}
