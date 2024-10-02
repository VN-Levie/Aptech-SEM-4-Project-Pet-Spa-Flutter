import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/constants/app_const.dart';
import 'dart:io';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/pets/list_pet.dart';
import 'package:project/widgets/dropdown_input.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/input.dart'; // Import Input widget
import 'package:project/core/rest_service.dart'; // Import dịch vụ gọi API
import 'package:http/http.dart' as http;
import 'package:project/widgets/utils.dart'; // Để gửi multipart request

class PetFormScreen extends StatefulWidget {
  final int? petId; // Thêm biến petId để kiểm tra chế độ edit
  const PetFormScreen({super.key, this.petId});

  @override
  _PetFormScreenState createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final AppController appController = Get.put(AppController());
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // Biến để hiển thị trạng thái loading
  bool _isEditMode = false; // Biến để kiểm tra xem có đang trong chế độ chỉnh sửa không
  String? _petImageUrl;

  // Controllers để lấy giá trị từ form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Biến để lưu trữ ảnh
  File? _petImage;

  // Biến để lưu trữ loại thú cưng
  List<Map<String, dynamic>> petTypes = [];
  String? selectedPetType;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = 'A lovely pet'; // Mặc định mô tả
    if (widget.petId != null) {
      _isEditMode = true;
      _fetchPetDetails(widget.petId!); // Gọi hàm lấy thông tin thú cưng khi vào edit mode
    }
    _fetchPetTypes(); // Lấy danh sách loại thú cưng khi vào chế độ thêm mới
  }

  // Lấy danh sách loại thú cưng từ API
  Future<void> _fetchPetTypes() async {
    const String apiUrl = '/api/pets/types';
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data.isNotEmpty) {
          setState(() {
            petTypes = List<Map<String, dynamic>>.from(data);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pet types: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pet types: $e')),
      );
    }
  }

  // Hàm lấy thông tin pet từ API
  Future<void> _fetchPetDetails(int petId) async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });
    int accountId = appController.account.id;
    try {
      //http://localhost:8090/api/pets/1/1 | @GetMapping("/{accountId}/{petId}")
      var response = await RestService.get('/api/pets/$accountId/$petId'); // Gọi API để lấy thông tin thú cưng
      print('/api/pets/$accountId/$petId');
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data['deleted'] == true || data.isEmpty) {
          Utils.noti('Pet not found');
          Navigator.pop(context, 'update');
        } else {
          // Cập nhật dữ liệu lên form
          _nameController.text = data['name'];
          _descriptionController.text = data['description'];
          _heightController.text = data['height'].toString();
          _weightController.text = data['weight'].toString();
          selectedPetType = data['petTypeId'].toString();
          //_petImage = File(Utils.replaceLocalhost(data['avatarUrl'])); // Giả sử avatarUrl trả về đường dẫn ảnh
          _petImageUrl = Utils.replaceLocalhost(data['avatarUrl']); // Lưu đường dẫn ảnh từ server

          setState(() {
            _isLoading = false; // Hoàn thành việc tải
          });
        }
      } else {
        Utils.noti('Pet not found!');
        Navigator.pop(context, 'update');
      }
    } catch (e) {
      Utils.noti('Pet not found.');
      Navigator.pop(context, 'update');
    }
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate() && selectedPetType != null) {
      String name = _nameController.text;
      String height = _heightController.text;
      String weight = _weightController.text;
      String description = _descriptionController.text;
      int accountId = appController.account.id;
      // Đảm bảo height và weight là số
      if (double.tryParse(height) == null || double.tryParse(weight) == null) {
        Utils.noti('Height and weight must be numbers');
        return;
      }

      if (_petImage == null && _petImageUrl == null) {
        Utils.noti('Please select an image');
        return;
      }

      var uri = Uri.parse('${AppConst.apiEndpoint}/api/pets/$accountId/${widget.petId}'); // API URL
      var request = http.MultipartRequest('PUT', uri); // Chuyển thành PUT

      // Thêm các field vào form
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['height'] = height;
      request.fields['weight'] = weight;
      request.fields['accountId'] = accountId.toString();
      request.fields['petTypeId'] = selectedPetType!;
      if (_petImage != null) {
        // Thêm file ảnh vào form
        var pic = await http.MultipartFile.fromPath('avatar', _petImage!.path, contentType: MediaType('image', 'jpeg'));
        request.files.add(pic);
      }
      // Gửi request
      var response = await request.send();

      if (response.statusCode == 200) {
        try {
            String apiCount = '/api/pets/count/$accountId';
            var responseCount = await RestService.get(apiCount);
            if (responseCount.statusCode == 200) {
              var jsonResponse = jsonDecode(responseCount.body);
              appController.setPetCount(jsonResponse['data']);
            }
          } catch (e) {
            Utils.noti('Error while updating pet count');
          }
        Utils.noti('Pet updated successfully');
        Navigator.pop(context, 'success'); // Trả về kết quả thành công
      } else if (response.statusCode == 400) {
        var responseString = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseString);
        Utils.noti("${jsonResponse['message']}");
      } else if (response.statusCode == 404) {
        Utils.noti('Pet not found');
        Navigator.pop(context, 'update');
      } else {
        Utils.noti('Something went wrong. Please try again later');
      }
    } else {
      Utils.noti('Please fill in all required fields');
    }
  }

  // Hàm gọi API thêm thú cưng (POST)
  Future<void> _addPet() async {
    if (_formKey.currentState!.validate() && selectedPetType != null) {
      String name = _nameController.text;
      String height = _heightController.text;
      String weight = _weightController.text;
      String description = _descriptionController.text;

      //đảm bảo height và weight là số
      if (double.tryParse(height) == null || double.tryParse(weight) == null) {
        Utils.noti('Height and weight must be numbers');
        return;
      }

      if (_petImage != null) {
        int accountId = appController.account.id;
        var uri = Uri.parse('${AppConst.apiEndpoint}/api/pets/add'); // API URL
        var request = http.MultipartRequest('POST', uri);

        // Thêm các field vào form
        request.fields['name'] = name;
        request.fields['description'] = description;
        request.fields['height'] = height;
        request.fields['weight'] = weight;
        request.fields['accountId'] = accountId.toString();
        request.fields['petTypeId'] = selectedPetType!;

        // Thêm file ảnh vào form
        var pic = await http.MultipartFile.fromPath('avatar', _petImage!.path, contentType: MediaType('image', 'jpeg'));
        request.files.add(pic);

        // Gửi request
        var response = await request.send();

        if (response.statusCode == 201) {
          try {
            String apiCount = '/api/pets/count/$accountId';
            var responseCount = await RestService.get(apiCount);
            if (responseCount.statusCode == 200) {
              var jsonResponse = jsonDecode(responseCount.body);
              appController.setPetCount(jsonResponse['data']);
            }
          } catch (e) {
            Utils.noti('Error while updating pet count');
          }

          Utils.noti('Pet added successfully');
          Navigator.pop(context, 'success'); // Trả về kết quả thành công
        } else if (response.statusCode == 400) {
          var responseString = await response.stream.bytesToString();
          var jsonResponse = jsonDecode(responseString);
          Utils.noti("${jsonResponse['message']}");
        } else {
          Utils.noti('Something went wrong. Please try again later');
        }
      } else {
        Utils.noti('Please select an image');
      }
    } else {
      Utils.noti('Please fill in all required fields');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _petImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: _isEditMode ? 'Edit Pet' : 'Add New Pet', // Tùy theo chế độ
        backButton: true,
        rightOptions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading nếu đang tải dữ liệu
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị ảnh thú cưng
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _showImageSourceActionSheet(context);
                          },
                          child: Container(
                            width: 320, // Chiều rộng của ảnh
                            height: 240, // Chiều cao của ảnh
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: MaterialColors.primary.withOpacity(0.7),
                            ),
                            child: _petImage != null // Nếu đã chọn ảnh từ thiết bị
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _petImage!, // Hiển thị ảnh từ file local
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : (widget.petId != null && Utils.replaceLocalhost(_petImageUrl ?? '') != null) // Nếu đang trong chế độ sửa pet và có ảnh từ server
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          Utils.replaceLocalhost(_petImageUrl ?? ''), // Hiển thị ảnh từ URL (server)
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.error, size: 50, color: Colors.red);
                                          },
                                        ),
                                      )
                                    : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey), // Nếu không có ảnh nào được chọn
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nhập tên thú cưng với Input widget
                      Input(
                        placeholder: 'Pet Name',
                        controller: _nameController,
                        outlineBorder: false,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pet name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Dropdown để chọn loại thú cưng
                      DropdownInput(
                        placeholder: 'Select Pet Type',
                        items: petTypes.map<DropdownMenuItem<String>>((petType) {
                          return DropdownMenuItem<String>(
                            value: petType['id'].toString(),
                            child: Text(petType['name']),
                          );
                        }).toList(),
                        value: selectedPetType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPetType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a pet type';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nhập chiều cao với Input widget
                      Input(
                        placeholder: 'Height (cm)',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        outlineBorder: false,
                        enabledBorderColor: MaterialColors.muted,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pet height';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nhập cân nặng với Input widget
                      Input(
                        placeholder: 'Weight (kg)',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        outlineBorder: false,
                        enabledBorderColor: MaterialColors.muted,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pet weight';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nhập mô tả với Input widget
                      Input(
                        placeholder: 'Description',
                        controller: _descriptionController,
                        maxLines: 4,
                        outlineBorder: false,
                        enabledBorderColor: MaterialColors.muted,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Nút thêm/cập nhật thú cưng
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isEditMode ? _updatePet : _addPet, // Gọi update hoặc add tùy chế độ
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: MaterialColors.primary.withOpacity(0.9),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          icon: Icon(_isEditMode ? Icons.edit : Icons.add, color: MaterialColors.caption),
                          label: Text(_isEditMode ? 'Update Pet' : 'Add Pet', style: const TextStyle(color: MaterialColors.caption)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
