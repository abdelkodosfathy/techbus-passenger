import 'dart:convert';
import 'dart:math' as math;
import 'package:busapp/signin_signup_screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:busapp/models/user_model.dart';
import 'package:busapp/services_screens/complaint.dart';
import 'package:busapp/services_screens/payment_screens/payment_ammount.dart';
import 'package:busapp/services_screens/tickets_screen.dart' as myTicketScreen;
import 'package:busapp/shared/network/local_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  int points = 0;
  int tickets = 0;
  File? _pickedImage;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> logout(BuildContext context) async {
  try {
    await CashNetwork.removeCacheData(key: 'user_data');
    await CashNetwork.removeCacheData(key: 'token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,);
  } catch (e) {
    print("Logout failed: $e");
    // Optionally show an error toast or snackbar
  }
}


  Future<void> _loadUserData() async {
    
    try {
      // 1. Load from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final sharedBalance = prefs.getDouble('balance')?.toInt() ?? 0;
      
      // 2. Load from cached user data
      final userData = CashNetwork.getCacheData(key: 'user_data');
      UserModel? cachedUser;
      int cachedPoints = 0;
      
      if (userData.isNotEmpty) {
        try {
          cachedUser = UserModel.fromJson(json.decode(userData));
          cachedPoints = cachedUser.balance.points;
        } catch (e) {
          print('Error parsing user data: $e');
        }
      }
      
      // 3. Use the highest available value
      final newPoints = math.max(sharedBalance, cachedPoints);
      
      setState(() {
        points = newPoints;
        userModel = cachedUser;
        
        if (userModel != null) {
          userModel = userModel!.copyWith(
            balance: userModel!.balance.copyWith(points: newPoints)
          );
        }
      });
      
      // Sync all data sources
      if (sharedBalance < newPoints) {
        await prefs.setDouble('balance', newPoints.toDouble());
      }
      if (cachedUser?.balance.points != newPoints) {
        await CashNetwork.saveCacheData(
          key: 'user_data',
          value: json.encode(userModel?.toJson()),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Future<void> _pickAndUploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     final uri = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/update-profile');
  //     final request = http.MultipartRequest('POST', uri);
      
  //     request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));
  //     // Add token or other headers if required
  //     final response = await request.send();
      
  //     if (response.statusCode == 200) {
  //       _loadUserData(); // Refresh the profile image
  //     } else {
  //       print('Image upload failed with status ${response.statusCode}');
  //     }
  //   }
  // }
  // Future<void> _pickAndUploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     final uri = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/update-profile');
  //     final request = http.MultipartRequest('POST', uri);

  //     // Add image file
  //     request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

  //     // ✅ Add headers (like auth token)
  //     final token = CashNetwork.getCacheData(key: 'token'); // If you store token this way
  //     request.headers.addAll({
  //       'Authorization': 'Bearer $token',
  //       'Accept': 'application/json',
  //     });

  //     try {
  //       final response = await request.send();
  //       final resBody = await response.stream.bytesToString();
  //       // print('✅ Image uploaded successfully: $resBody');

  //       if (response.statusCode == 200) {
  //         print('✅ Image uploaded successfully: $resBody');
  //         _loadUserData(); // Refresh the profile image
  //       } else {
  //         print('❌ Image upload failed with status ${response.statusCode}');
  //         final body = await response.stream.bytesToString();
  //         print('Response body: $body');
  //       }
  //     } catch (e) {
  //       print('❌ Error uploading image: $e');
  //     }
  //   } else {
  //     print('❗ No image was picked');
  //   }
  // }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      print('❗ No image was picked');
      return;
    }

    final uri = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/update-profile');
    final request = http.MultipartRequest('POST', uri);

    // Attach the image file
    request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

    // ✅ Retrieve token correctly
    final token = await CashNetwork.getCacheData(key: 'token');
    if (token != null) {
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
    }

    try {
      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ Image uploaded successfully: $resBody');

        final data = json.decode(resBody);
        final newImageUrl = data['data']['image'];

        // ✅ Update cached user data
        final cachedUser = await CashNetwork.getCacheData(key: 'user_data');
        if (cachedUser != null) {
          final userMap = json.decode(cachedUser);
          userMap['data']['image'] = newImageUrl;

          await CashNetwork.saveCacheData(
            key: 'user_data',
            value: json.encode(userMap),
          );

          print('✅ Cached user data updated with new image.');
        }

        // ✅ Optionally update local userModel if available
        setState(() {
          if (userModel != null) {
            userModel = userModel!.copyWith(image: newImageUrl);
          }
        });

        _loadUserData(); // Refresh UI or refetch
      } else {
        print('❌ Upload failed with status: ${response.statusCode}');
        print('❌ Response body: $resBody');
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
    }
  }



Widget _buildProfileAvatar() {
  // 1. Use the picked image from the device
  if (_pickedImage != null) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: FileImage(_pickedImage!),
    );
  }

    print("user image is: $userModel");
  // 2. Use the image from the network if available
  if (userModel?.image != null && userModel!.image.isNotEmpty) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: Image.network(
          userModel!.image,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load image: $error');
            return _buildInitialsFallback(); // Show initials if loading fails
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // 3. Default to initials if no image is set
  return _buildInitialsAvatar();
}

  Widget _buildInitialsFallback() {
    final firstNameInitial = userModel?.firstName.isNotEmpty ?? false 
        ? userModel!.firstName[0] 
        : '';
    final lastNameInitial = userModel?.lastName.isNotEmpty ?? false 
        ? userModel!.lastName[0] 
        : '';
    return Text(
      '$firstNameInitial$lastNameInitial',
      style: const TextStyle(fontSize: 24),
    );
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: 50,
     // backgroundColor: const Color(0xFF0F5A5F),
      child: _buildInitialsFallback(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 15, 90, 95),
        surfaceTintColor:  Color.fromARGB(255, 15, 90, 95),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logoWhite.png',
              width: 192,
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        toolbarHeight: 80,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Column(
            children: [
              Row(
                children: [
                Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                  _buildProfileAvatar(),
                    Positioned(
                      width: 40,
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:  Color.fromARGB(255, 15, 90, 95),
                            width: 4,
                          ),
                        ),
                        child: IconButton( onPressed: _pickAndUploadImage,
                        icon: Icon(
                          Icons.edit,
                          color:  Color.fromARGB(255, 15, 90, 95),
                          size: 16,
                        ),)
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(height: 50,),
              Text(
                '${userModel?.firstName ?? 'First'} ${userModel?.lastName ?? 'Last'}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userModel?.email ?? 'email',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 26,),
                SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userModel: userModel!),
                  ),
                ).then((updatedUser) {
                  if (updatedUser != null && updatedUser is UserModel) {
                    setState(() {
                      userModel = updatedUser;
                    });
                  }
                });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0A6A6A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Edit Profile',style: TextStyle(color: Colors.white)),
                ),
              ),          
                ],
              ),
                ],
              ),
                SizedBox(height: 26),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStatCard(points.toString(), 'Points'),
                    SizedBox(height: 20),
                    _buildMenuOption(
                      icon: Icons.monetization_on,
                      iconColor: Colors.amber,
                      iconBgColor: Color(0xFFFFF8E1),
                      title: 'Charge My points',
                      onPressed: () async {
                        final result = await Navigator.push<double>(
                          context,
                          MaterialPageRoute(builder: (context) => PaymentAmount()),
                        );
                        
                        if (result != null) {
                          await _loadUserData(); // Refresh data after returning
                        }
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.confirmation_number_outlined,
                      iconColor: Colors.blue,
                      iconBgColor: Color(0xFFE3F2FD),
                      title: 'View Tickets',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => myTicketScreen.TicketsScreen()),
                        );
                    },
                    ),
                    _buildMenuOption(
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      iconBgColor: Color(0xFFFFEBEE),
                      title: 'Make a complaint',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ComplaintSrc()),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          print('Log out'); // Your log-out logic goes here
                          logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.red,
                              width: 2.0,
                            ),
                          ),
                          padding: EdgeInsets.all(0),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                'Log out',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
// ElevatedButton(
//   onPressed: () async {
//     final prefs = await SharedPreferences.getInstance();
//     final sharedBalance = prefs.getDouble('balance')?.toInt() ?? 0;

//     final userData = CashNetwork.getCacheData(key: 'user_data');
//     UserModel? cachedUser;
//     int cachedPoints = 0;

//     if (userData.isNotEmpty) {
//       try {
//         cachedUser = UserModel.fromJson(json.decode(userData));
//         cachedPoints = cachedUser.balance.points;
//       } catch (e) {
//         print('Error parsing user data: $e');
//       }
//     }

//     final newPoints = math.max(sharedBalance, cachedPoints);

//     print('------------------------------');
//     print('SharedPreferences points: $sharedBalance');
//     print('Cached user points: $cachedPoints');
//     print('Final points used: $newPoints');
//     print('UserModel: ${cachedUser?.toJson()}');
//     print('------------------------------');
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.blueGrey,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(12),
//     ),
//   ),
//   child: Text('Print Debug Info'),
// ),

                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

 Widget _buildStatCard(String value, String label) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          (userModel?.balance.points ?? points).toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}

  Widget _buildMenuOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onPressed, 
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, 
          foregroundColor: Colors.black,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(0), 
        ),
        onPressed: onPressed, 
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}


//edit profile screen
class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  EditProfileScreen({required this.userModel});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userModel.firstName);
    _lastNameController = TextEditingController(text: widget.userModel.lastName);
    _emailController = TextEditingController(text: widget.userModel.email);
  }

  Future<void> _updateProfile() async {
  final uri = Uri.parse('https://tech-bus-egy.vercel.app/mobile/user/update-profile');
  final token = CashNetwork.getCacheData(key: 'token');

  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
    }),
  );

  if (response.statusCode == 200) {
    final updatedUser = widget.userModel.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
    );

    Navigator.pop(context, updatedUser); // رجع النسخة الجديدة
  } else {
    print('Update failed: ${response.statusCode}');
  }
}

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    ),
    title: const Text(
      "Edit Profile",
      style: TextStyle(color: Colors.black),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'First Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your first name',
                  contentPadding: const EdgeInsets.all(16.0),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0F5A5F), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Last Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: 'Enter your last name',
                  contentPadding: const EdgeInsets.all(16.0),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0F5A5F), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  contentPadding: const EdgeInsets.all(16.0),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0F5A5F), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5A5F), // Using the same teal color
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _updateProfile,
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}


// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_initials: ^1.0.3

// flutter_icons: 
//   android: true
//   ios: true
//   image_path: "assets/images/icon.png"