import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:samehgroup/config/api.dart';

class HttpUploadService {
  Future<String> uploadPhotos(List<String> paths, String number) async {
    Uri uri = Uri.parse(Api.uploadImages);
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    for (String path in paths) {
      request.files.add(await http.MultipartFile.fromPath('files[]', path));
      request.fields['number'] = number;
    }

    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    print('\n\n');
    print('RESPONSE WITH HTTP');
    print(responseString);
    print('\n\n');
    return responseString;
  }
}
