import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

//get Details
String host = '192.168.100.184';
String detailsPath = '/moodle/webservice/rest/server.php';
String extFuncPath = '/moodle/webservice/rest/server.php';

class DetailsResponse {
  final String sitename;
  final String fullname;
  final int userId;

  DetailsResponse({this.sitename, this.fullname, this.userId});

  factory DetailsResponse.fromJson(Map<String, dynamic> json) {
    return DetailsResponse(
        sitename: json['sitename'] as String,
        fullname: json['fullname'] as String,
        userId: json['userid'] as int);
  }
}

Future<DetailsResponse> getDetails(String token) async {
  Map<String, String> myQuery = {
    'moodlewsrestformat': 'json',
    'wsfunction': 'core_webservice_get_site_info',
    'wstoken': token,
    'moodlewssettingfilter': 'true',
    'moodlewssettingfileurl': 'true',
  };

  var uri = Uri(
    scheme: 'http',
    host: host,
    port: 80,
    path: detailsPath,
    queryParameters: myQuery,
  );

  var response = await http.post(uri);

  Map<String, dynamic> resp = jsonDecode(response.body);
  DetailsResponse lr = new DetailsResponse.fromJson(resp);
  print(lr.fullname + lr.sitename);

  return lr;
}

//parsing output of tool_mobile_call_external_functions

class ExternalFunctionOutput {
  bool error;
  String data;

  ExternalFunctionOutput({this.error, this.data});

  factory ExternalFunctionOutput.fromJson(Map<String, dynamic> json1) {
    return ExternalFunctionOutput(
      error: json1['error'] as bool,
      data: json1['data'] as String, //functio parsedata
    );
  }
}

List<ExternalFunctionOutput> getL(List<dynamic> json1) {
  List<ExternalFunctionOutput> nList = new List<ExternalFunctionOutput>();
//print('hrrr');
//print(json1[0].runtimeType);
  for (int i = 0; i < json1.length; i++) {
    nList.add(new ExternalFunctionOutput.fromJson(json1[0]));
//print(nList[i].data);
  }
  return nList;
}

class ExternalFunctionOutputs {
  List<ExternalFunctionOutput> responses;
  ExternalFunctionOutputs({this.responses});

  factory ExternalFunctionOutputs.fromJson(Map<String, dynamic> json1) {
    return ExternalFunctionOutputs(responses: getL(json1['responses']));
  }
}
//parsing coursedetails

/// id
/// name
/// summary
/// progress
class CourseDetails {
  int id;
  String name;
  String summary;
  //double progress;
  CourseDetails({this.id, this.name, this.summary});
  factory CourseDetails.fromJson(Map<String, dynamic> json1) {
    return CourseDetails(
      id: json1['id'] as int,
      name: json1['fullname'] as String,
      summary: json1['summary'] as String,
    );
  }
}

Future<List<CourseDetails>> getCoursesDetails(String token, int userId) async {
  Map<String, String> myQuery = {
    'moodlewsrestformat': 'json',
    'wsfunction': 'tool_mobile_call_external_functions',
    'wstoken': token,
    'moodlewssettingfilter': 'true',
    'moodlewssettingfileurl': 'true',
    'requests[0][function]': 'core_enrol_get_users_courses',
    'requests[0][arguments]':
        '{"userid":"' + userId.toString() + '","returnusercount":"0"}',
    'requests[0][settingfilter]': '1',
    'requests[0][settingfileurl]': '1',
  };

  var uri = Uri(
    scheme: 'http',
    host: host,
    port: 80,
    path: extFuncPath,
    queryParameters: myQuery,
  );

  var response = await http.post(uri);

  Map<String, dynamic> resp = jsonDecode(response.body);

  ExternalFunctionOutputs lr = new ExternalFunctionOutputs.fromJson(resp);
  ExternalFunctionOutput myCoursesAll = lr.responses[0];
  List<dynamic> nList = jsonDecode(myCoursesAll.data);
  List<CourseDetails> myCourses = new List<CourseDetails>();
  for (int i = 0; i < nList.length; i++) {
    CourseDetails myCourse = new CourseDetails.fromJson(nList[i]);
    myCourses.add(myCourse);
  }

  //print(lr.responses[0].data);

  return myCourses;
}

//CourseContents parsing TODO this

//////////
// Get Assignments of a Course
/*
"id":1,
"cmid":4,
"course":3,
"name":"Assignment `",
"nosubmissions":0,
"submissiondrafts":0,
"sendnotifications":0,
"sendlatenotifications":0,
"sendstudentnotifications":1,
"duedate":1602613800,
"allowsubmissionsfromdate":1602009000,
"grade":100,
"timemodified":1602061213,
"completionsubmit":1,
"cutoffdate":0,
"gradingduedate":1603218600,
"teamsubmission":0,
"requireallteammemberssubmit":0,
"teamsubmissiongroupingid":0,
"blindmarking":0,
"hidegrader":0,
"revealidentities":0,
"attemptreopenmethod":"none",
"maxattempts":-1,
"markingworkflow":0,
"markingallocation":0,
"requiresubmissionstatement":0,
"preventsubmissionnotingroup":0, */
/// need to update this later to include all features of the app :0
class AssignmentDetails {
  int id;
  int cmid;
  int courseId;
  String name;
  int duedate;
  int startdate;
  int grade;
  int completed;

  AssignmentDetails(
      {this.id,
      this.cmid,
      this.courseId,
      this.name,
      this.duedate,
      this.startdate,
      grade,
      this.completed});
  factory AssignmentDetails.fromJson(Map<String, dynamic> json1) {
    return AssignmentDetails(
      id: json1['id'] as int,
      cmid: json1['cmid'] as int,
      courseId: json1['course'] as int,
      name: json1['name'] as String,
      duedate: json1['duedate'] as int,
      startdate: json1['allowsubmissionsfromdate'] as int,
      grade: json1['grade'] as int,
      completed: json1['completionsubmit'] as int,
    );
  }
}

List<AssignmentDetails> getAsList(List<dynamic> assignments) {
  List<AssignmentDetails> assignmentsD = new List<AssignmentDetails>();
  for (int i = 0; i < assignments.length; i++) {
    AssignmentDetails myAss = new AssignmentDetails.fromJson(assignments[i]);
    assignmentsD.add(myAss);
  }
  return assignmentsD;
}

class AssignmentsofCourse {
  int courseId;
  String courseName;
  List<AssignmentDetails> assignments;

  AssignmentsofCourse({this.courseId, this.courseName, this.assignments});
  factory AssignmentsofCourse.fromJson(Map<String, dynamic> json1) {
    return AssignmentsofCourse(
        courseId: json1['course'] as int,
        courseName: json1['fullname'] as String,
        assignments: getAsList(json1['assignments']));
  }
}

Future<AssignmentsofCourse> getAssignments(String token, int courseId) async {
  Map<String, String> myQuery = {
    'moodlewsrestformat': 'json',
    'wsfunction': 'mod_assign_get_assignments',
    'wstoken': token,
    'moodlewssettingfilter': 'true',
    'moodlewssettingfileurl': 'true',
    'courseids[0]': courseId.toString()
  };

  var uri = Uri(
    scheme: 'http',
    host: host,
    port: 80,
    path: detailsPath,
    queryParameters: myQuery,
  );

  var response = await http.post(uri);

  Map<String, dynamic> resp = jsonDecode(response.body);
  AssignmentsofCourse lr = new AssignmentsofCourse.fromJson(resp['courses'][0]);
  print(resp['courses'][0].runtimeType);
  //print('Okay '+lr.courseName);

  return lr;
}

///// Check assignment submission

Future<bool> checkAssignmentSubmission(
    String token, int userId, int assignmentId) async {
  Map<String, String> myQuery = {
    'moodlewsrestformat': 'json',
    'wsfunction': 'mod_assign_get_submission_status',
    'wstoken': token,
    'moodlewssettingfilter': 'true',
    'moodlewssettingfileurl': 'true',
    'assignid': assignmentId.toString(),
    'userid': userId.toString(),
  };

  var uri = Uri(
    scheme: 'http',
    host: host,
    port: 80,
    path: detailsPath,
    queryParameters: myQuery,
  );

  var response = await http.post(uri);

  Map<String, dynamic> resp = jsonDecode(response.body);
  print(resp['lastattempt']['submission']['status']);
  if (resp['lastattempt']['submission']['status'] == 'new') {
    print('not submitted');
    return false;
  } else {
    print('already submitted');
    return true;
  }
  //print('Okay '+lr.courseName);
}
//upload file

class FileUploadResponse {
  bool success;
  int itemId;
  String fileName;
  String fileArea;
  int contextId;
  FileUploadResponse(
      {this.success,
      this.itemId,
      this.fileArea,
      this.fileName,
      this.contextId});
  factory FileUploadResponse.fromJson(Map<String, dynamic> json1) {
    return FileUploadResponse(
        success: json1['error']!=null ? false : true,
        itemId: json1['itemid'] as int,
        fileName: json1['filename'] as String,
        fileArea: json1['filearea'] as String,
        contextId: json1['contextid'] as int);
  }
}

Future<bool> uploadFile(String token, String file, String filename,
    int assignmentId, int userId) async {
  BaseOptions options = new BaseOptions(
    baseUrl: 'http://' + host ,
    connectTimeout: 5000,
    receiveTimeout: 3000,
  );
  Dio dio = new Dio(options);
  FormData formData = FormData.fromMap({
    "token": token,
    "filearea": 'draft',
    "itemid": "0",
    "file": await MultipartFile.fromFile(file)
  });
  print('Starting upload');
  Response response = await dio.post('/moodle/webservice/upload.php', data: formData);
  print('uploading file..');
  Map<String, dynamic> resp = jsonDecode(response.data)[0];
  FileUploadResponse lr = new FileUploadResponse.fromJson(resp);
  print(lr.itemId);
  if (lr.success == false) return false;
  print('file uploaded.. verifying..');
  Map<String, String> myQuery = {
    'moodlewsrestformat': 'json',
    'wsfunction': 'mod_assign_save_submission',
    'wstoken': token,
    'moodlewssettingfilter': 'true',
    'moodlewssettingfileurl': 'true',
    'assignmentid': assignmentId.toString(),
    'plugindata[files_filemanager]': lr.itemId.toString()
  };
  print(myQuery);
  var uri = Uri(
    scheme: 'http',
    host: host,
    port: 80,
    path: detailsPath,
    queryParameters: myQuery,
  );

  var response1 = await http.post(uri);
  print(jsonDecode(response1.body));
  return await checkAssignmentSubmission(token, userId, assignmentId);
}
