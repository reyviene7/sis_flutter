import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CourseManagementPage(),
    );
  }
}

class CourseManagementPage extends StatefulWidget {
  @override
  _CourseManagementPageState createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  TextEditingController courseIdController = TextEditingController();
  TextEditingController courseNameController = TextEditingController();

  List<Course> courses = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final response = await http.get(Uri.parse('http://localhost:5000/courses'));
    if (response.statusCode == 200) {
      final List<dynamic> coursesJson = jsonDecode(response.body)['data'];
      setState(() {
        courses = coursesJson.map((courseJson) => Course.fromJson(courseJson)).toList();
      });
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<void> addCourse(String courseName) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/course'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'course': courseName,
      }),
    );
    if (response.statusCode == 200) {
      fetchCourses();
    } else {
      throw Exception('Failed to add course');
    }
  }

  Future<void> updateCourse(int courseId, String newCourseName) async {
    final response = await http.put(
      Uri.parse('http://localhost:5000/course/$courseId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'course': newCourseName,
      }),
    );
    if (response.statusCode == 200) {
      fetchCourses();
    } else {
      throw Exception('Failed to update course');
    }
  }

  Future<void> deleteCourse(int courseId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:5000/course/$courseId'),
    );
    if (response.statusCode == 200) {
      fetchCourses();
    } else {
      throw Exception('Failed to delete course');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Available Courses',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('ID: ${courses[index].courseId}, Name: ${courses[index].courseName}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await deleteCourse(courses[index].courseId);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: courseNameController,
                decoration: InputDecoration(
                  labelText: 'New Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await addCourse(courseNameController.text);
                  courseNameController.clear();
                },
                child: Text('Add Course'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: courseIdController,
                decoration: InputDecoration(
                  labelText: 'Course ID to Update',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: courseNameController,
                decoration: InputDecoration(
                  labelText: 'New Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await updateCourse(int.parse(courseIdController.text), courseNameController.text);
                  courseIdController.clear();
                  courseNameController.clear();
                },
                child: Text('Update Course'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Course {
  final int courseId;
  final String courseName;

  Course({required this.courseId, required this.courseName});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      courseName: json['course_name'],
    );
  }
}
