// lib/data/sample_data.dart
//
// IMPORTANT: Everything in this file is fictional demonstration data.
// It does not come from a real university database. The email domain
// ".demo" and the password below exist only so the frontend can run
// before the PHP API is connected.

import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/campus_event.dart';
import '../models/campus_task.dart';
import '../models/course.dart';
import '../models/faculty.dart';
import '../models/school_class.dart';
import '../models/student.dart';
import '../models/user.dart';

const String demoPassword = '1234';

class CampusData extends ChangeNotifier {
  CampusData._() {
    _seed();
    _refreshCounters();
  }

  static final CampusData instance = CampusData._();

  final List<User> users = [];
  final List<Faculty> faculties = [];
  final List<SchoolClass> classes = [];
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CampusTask> tasks = [];
  final List<CampusEvent> events = [];
  final List<Announcement> announcements = [];

  int _nextUserId = 1;
  int _nextStudentId = 1;
  int _nextTaskId = 1;
  int _nextEventId = 1;
  int _nextAnnouncementId = 1;

  // ---------------------------------------------------------------
  // Queries (the frontend version of SQL SELECT statements)
  // ---------------------------------------------------------------

  User? userById(int id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  User? userByUniversityId(String universityId) {
    final normalized = universityId.trim().toLowerCase();
    for (final user in users) {
      if (user.universityId.toLowerCase() == normalized) return user;
    }
    return null;
  }

  Faculty? facultyById(int id) {
    for (final faculty in faculties) {
      if (faculty.id == id) return faculty;
    }
    return null;
  }

  SchoolClass? classById(int id) {
    for (final schoolClass in classes) {
      if (schoolClass.id == id) return schoolClass;
    }
    return null;
  }

  Student? studentForUser(int userId) {
    for (final student in students) {
      if (student.userId == userId) return student;
    }
    return null;
  }

  SchoolClass? classForUser(int userId) {
    final student = studentForUser(userId);
    if (student == null) return null;
    return classById(student.classId);
  }

  Faculty? facultyForUser(int userId) {
    final schoolClass = classForUser(userId);
    if (schoolClass == null) return null;
    return facultyById(schoolClass.facultyId);
  }

  Course? courseById(int id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  List<Course> coursesForLecturer(int lecturerId) {
    return courses.where((course) => course.lecturerId == lecturerId).toList();
  }

  List<Student> studentsForClass(int classId) {
    return students.where((student) => student.classId == classId).toList();
  }

  List<CampusTask> tasksForStudent(int userId) {
    final result = tasks
        .where((task) => task.studentId == userId)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<CampusTask> tasksForCourse(int courseId) {
    return tasks.where((task) => task.courseId == courseId).toList();
  }

  int pendingTaskCount(int userId) {
    return tasks
        .where(
          (task) =>
              task.studentId == userId && task.status == TaskStatus.pending,
        )
        .length;
  }

  List<CampusEvent> upcomingEvents() {
    final result = events.where((event) => event.isUpcoming).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  List<Announcement> announcementsNewestFirst() {
    final result = [...announcements]
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return result;
  }

  // Important announcements appear first, then the newest ones.
  List<Announcement> announcementsForList() {
    final result = [...announcements]
      ..sort((a, b) {
        if (a.isImportant != b.isImportant) {
          return a.isImportant ? -1 : 1;
        }
        return b.publishedAt.compareTo(a.publishedAt);
      });
    return result;
  }

  int get totalUsers => users.length;
  int get totalStudents =>
      users.where((user) => user.role == Role.student).length;
  int get totalLecturers =>
      users.where((user) => user.role == Role.lecturer).length;
  int get totalAdmins => users.where((user) => user.role == Role.admin).length;
  int get totalAnnouncements => announcements.length;
  int get totalEvents => events.length;

  int uniqueStudentCountForLecturer(int lecturerId) {
    final classIds = coursesForLecturer(lecturerId)
        .map((course) => course.classId)
        .toSet();
    return students
        .where((student) => classIds.contains(student.classId))
        .length;
  }

  bool isUniversityIdTaken(String universityId, {int? ignoreUserId}) {
    final normalized = universityId.trim().toLowerCase();
    return users.any(
      (user) =>
          user.id != ignoreUserId &&
          user.universityId.toLowerCase() == normalized,
    );
  }

  // ---------------------------------------------------------------
  // Commands (the frontend version of INSERT / UPDATE / DELETE)
  // ---------------------------------------------------------------

  void updateTaskStatus(int taskId, TaskStatus status) {
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;
    tasks[index] = tasks[index].copyWith(status: status);
    notifyListeners();
  }

  // Creates one task for every student in the course class and returns
  // how many students received it.
  int addAssignmentForCourse({
    required Course course,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskType type,
  }) {
    final classStudents = studentsForClass(course.classId);
    for (final student in classStudents) {
      tasks.add(
        CampusTask(
          id: _nextTaskId++,
          courseId: course.id,
          courseName: course.name,
          studentId: student.userId,
          title: title.trim(),
          description: description.trim(),
          dueDate: dueDate,
          type: type,
        ),
      );
    }
    if (classStudents.isNotEmpty) notifyListeners();
    return classStudents.length;
  }

  int deleteAssignmentGroup({
    required int courseId,
    required String title,
    required DateTime dueDate,
  }) {
    final before = tasks.length;
    tasks.removeWhere(
      (task) =>
          task.courseId == courseId &&
          task.title == title &&
          task.dueDate.isAtSameMomentAs(dueDate),
    );
    final removed = before - tasks.length;
    if (removed > 0) notifyListeners();
    return removed;
  }

  User addUser({
    required String universityId,
    required String fullName,
    required String email,
    required String password,
    required Role role,
    required String department,
    int? classId,
    bool isActive = true,
  }) {
    final user = User(
      id: _nextUserId++,
      universityId: universityId.trim(),
      fullName: fullName.trim(),
      email: email.trim(),
      password: password.isEmpty ? demoPassword : password,
      role: role,
      department: department.trim(),
      isActive: isActive,
    );
    users.add(user);

    if (role == Role.student && classId != null) {
      students.add(
        Student(id: _nextStudentId++, userId: user.id, classId: classId),
      );
    }

    notifyListeners();
    return user;
  }

  void updateUser(User updated, {int? classId}) {
    final index = users.indexWhere((user) => user.id == updated.id);
    if (index == -1) return;
    users[index] = updated;

    final studentIndex = students.indexWhere(
      (student) => student.userId == updated.id,
    );

    if (updated.role == Role.student) {
      if (classId != null) {
        if (studentIndex == -1) {
          students.add(
            Student(
              id: _nextStudentId++,
              userId: updated.id,
              classId: classId,
            ),
          );
        } else {
          students[studentIndex] = Student(
            id: students[studentIndex].id,
            userId: updated.id,
            classId: classId,
          );
        }
      }
    } else if (studentIndex != -1) {
      students.removeAt(studentIndex);
    }

    notifyListeners();
  }

  void updateProfile({
    required int userId,
    required String fullName,
    required String email,
    required String department,
  }) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) return;
    users[index] = users[index].copyWith(
      fullName: fullName.trim(),
      email: email.trim(),
      department: department.trim(),
    );
    notifyListeners();
  }

  void setUserActive(int userId, bool isActive) {
    final index = users.indexWhere((user) => user.id == userId);
    if (index == -1) return;
    users[index] = users[index].copyWith(isActive: isActive);
    notifyListeners();
  }

  Announcement addAnnouncement({
    required String title,
    required String message,
    required String author,
    required AnnouncementCategory category,
    required bool isImportant,
  }) {
    final announcement = Announcement(
      id: _nextAnnouncementId++,
      title: title.trim(),
      message: message.trim(),
      publishedAt: DateTime.now(),
      author: author.trim(),
      category: category,
      isImportant: isImportant,
    );
    announcements.add(announcement);
    notifyListeners();
    return announcement;
  }

  void updateAnnouncement(Announcement updated) {
    final index =
        announcements.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    announcements[index] = updated;
    notifyListeners();
  }

  void deleteAnnouncement(int id) {
    announcements.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  CampusEvent addEvent({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required String location,
    required EventCategory category,
    required String organizer,
  }) {
    final event = CampusEvent(
      id: _nextEventId++,
      title: title.trim(),
      description: description.trim(),
      start: start,
      end: end,
      location: location.trim(),
      category: category,
      organizer: organizer.trim(),
    );
    events.add(event);
    notifyListeners();
    return event;
  }

  void updateEvent(CampusEvent updated) {
    final index = events.indexWhere((event) => event.id == updated.id);
    if (index == -1) return;
    events[index] = updated;
    notifyListeners();
  }

  void deleteEvent(int id) {
    events.removeWhere((event) => event.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Demonstration seed data
  // ---------------------------------------------------------------

  void _seed() {
    faculties.addAll(const [
      Faculty(id: 1, name: 'Faculty of Computing & IT'),
      Faculty(id: 2, name: 'Faculty of Engineering'),
      Faculty(id: 3, name: 'Faculty of Business & Economics'),
    ]);

    classes.addAll(const [
      SchoolClass(
        id: 1,
        name: 'CS-7A',
        semester: 7,
        facultyId: 1,
        department: 'Software Engineering',
      ),
      SchoolClass(
        id: 2,
        name: 'CS-5B',
        semester: 5,
        facultyId: 1,
        department: 'Computer Science',
      ),
      SchoolClass(
        id: 3,
        name: 'CS-3A',
        semester: 3,
        facultyId: 1,
        department: 'Information Systems',
      ),
      SchoolClass(
        id: 4,
        name: 'ENG-4A',
        semester: 4,
        facultyId: 2,
        department: 'Civil Engineering',
      ),
      SchoolClass(
        id: 5,
        name: 'BUS-2A',
        semester: 2,
        facultyId: 3,
        department: 'Business Administration',
      ),
    ]);

    users.addAll(const [
      User(
        id: 1,
        universityId: 'ADM01',
        fullName: 'Amina Hassan',
        email: 'amina.hassan@campushub.demo',
        password: demoPassword,
        role: Role.admin,
        department: 'Administration',
      ),
      User(
        id: 2,
        universityId: 'ADM02',
        fullName: 'Farhan Mohamed',
        email: 'farhan.mohamed@campushub.demo',
        password: demoPassword,
        role: Role.admin,
        department: "Registrar's Office",
      ),
      User(
        id: 3,
        universityId: 'LEC10',
        fullName: 'Ibrahim Ahmed',
        email: 'ibrahim.ahmed@campushub.demo',
        password: demoPassword,
        role: Role.lecturer,
        department: 'Computer Science',
      ),
      User(
        id: 4,
        universityId: 'LEC12',
        fullName: 'Abdirahman Yusuf',
        email: 'abdirahman.yusuf@campushub.demo',
        password: demoPassword,
        role: Role.lecturer,
        department: 'Software Engineering',
      ),
      User(
        id: 5,
        universityId: 'LEC14',
        fullName: 'Maryan Sheikh',
        email: 'maryan.sheikh@campushub.demo',
        password: demoPassword,
        role: Role.lecturer,
        department: 'Civil Engineering',
      ),
      User(
        id: 6,
        universityId: 'LEC15',
        fullName: 'Khalid Osman',
        email: 'khalid.osman@campushub.demo',
        password: demoPassword,
        role: Role.lecturer,
        department: 'Business Administration',
      ),
      User(
        id: 7,
        universityId: '20240153',
        fullName: 'Hodan Ali',
        email: 'hodan.ali@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 8,
        universityId: '20240154',
        fullName: 'Ahmed Mohamed',
        email: 'ahmed.mohamed@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 9,
        universityId: '20240155',
        fullName: 'Fatima Omar',
        email: 'fatima.omar@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 10,
        universityId: '20240156',
        fullName: 'Yusuf Abdi',
        email: 'yusuf.abdi@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 11,
        universityId: '20240157',
        fullName: 'Ayan Warsame',
        email: 'ayan.warsame@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 12,
        universityId: '20240158',
        fullName: 'Mohamed Nur',
        email: 'mohamed.nur@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Software Engineering',
      ),
      User(
        id: 13,
        universityId: '20240160',
        fullName: 'Sagal Farah',
        email: 'sagal.farah@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Computer Science',
      ),
      User(
        id: 14,
        universityId: '20240161',
        fullName: 'Liban Jama',
        email: 'liban.jama@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Computer Science',
      ),
      User(
        id: 15,
        universityId: '20240162',
        fullName: 'Hibo Aden',
        email: 'hibo.aden@campushub.demo',
        password: demoPassword,
        role: Role.student,
        department: 'Information Systems',
      ),
    ]);

    students.addAll(const [
      Student(id: 1, userId: 7, classId: 1),
      Student(id: 2, userId: 8, classId: 1),
      Student(id: 3, userId: 9, classId: 1),
      Student(id: 4, userId: 10, classId: 1),
      Student(id: 5, userId: 11, classId: 1),
      Student(id: 6, userId: 12, classId: 1),
      Student(id: 7, userId: 13, classId: 2),
      Student(id: 8, userId: 14, classId: 2),
      Student(id: 9, userId: 15, classId: 3),
    ]);

    courses.addAll(const [
      Course(
        id: 1,
        code: 'CS-701',
        name: 'Mobile Application Development',
        lecturerId: 3,
        classId: 1,
        schedule: 'Mon & Wed · 10:00 - 11:30',
        room: 'Lab 204',
        credits: 4,
        description:
            'Design and build cross-platform mobile applications with Flutter, '
            'covering widgets, navigation, state management, and REST APIs.',
      ),
      Course(
        id: 2,
        code: 'CS-702',
        name: 'Computer Networks',
        lecturerId: 3,
        classId: 1,
        schedule: 'Tue & Thu · 08:30 - 10:00',
        room: 'Room 301',
        credits: 3,
        description:
            'Network models, addressing, routing, transport protocols, and '
            'practical packet analysis using industry tools.',
      ),
      Course(
        id: 3,
        code: 'CS-703',
        name: 'Database Systems',
        lecturerId: 3,
        classId: 1,
        schedule: 'Sun & Tue · 12:00 - 13:30',
        room: 'Lab 101',
        credits: 3,
        description:
            'Relational database design, normalization, SQL, transactions, '
            'and the foundations of secure data storage.',
      ),
      Course(
        id: 4,
        code: 'CS-511',
        name: 'Software Engineering',
        lecturerId: 4,
        classId: 2,
        schedule: 'Mon & Thu · 09:00 - 10:30',
        room: 'Room 205',
        credits: 3,
        description:
            'Requirements, software design, testing, project planning, and '
            'team-based development practices.',
      ),
      Course(
        id: 5,
        code: 'ENG-401',
        name: 'Structural Analysis',
        lecturerId: 5,
        classId: 4,
        schedule: 'Wed · 08:00 - 11:00',
        room: 'Engineering Hall 2',
        credits: 4,
        description:
            'Analysis of beams, frames, and trusses with an introduction to '
            'modern structural design methods.',
      ),
      Course(
        id: 6,
        code: 'BUS-201',
        name: 'Principles of Management',
        lecturerId: 6,
        classId: 5,
        schedule: 'Tue · 14:00 - 16:00',
        room: 'Room B12',
        credits: 3,
        description:
            'Planning, organizing, leading, and controlling in contemporary '
            'organizations, with practical case studies.',
      ),
    ]);

    final now = DateTime.now();
    tasks.addAll([
      CampusTask(
        id: 1,
        courseId: 1,
        courseName: 'Mobile Application Development',
        studentId: 7,
        title: 'Build a login screen',
        description:
            'Create a responsive Flutter login screen with form validation, '
            'a password visibility toggle, and an error message for invalid '
            'credentials. Submit the source code and two screenshots.',
        dueDate: _daysFrom(now, 2, 23, 59),
        type: TaskType.assignment,
      ),
      CampusTask(
        id: 2,
        courseId: 2,
        courseName: 'Computer Networks',
        studentId: 7,
        title: 'Network security quiz',
        description:
            'Complete the online quiz covering symmetric and asymmetric '
            'encryption, TLS handshakes, and common network attacks. The quiz '
            'is open for one attempt only.',
        dueDate: _daysFrom(now, 4, 9, 0),
        type: TaskType.quiz,
      ),
      CampusTask(
        id: 3,
        courseId: 3,
        courseName: 'Database Systems',
        studentId: 7,
        title: 'Normalize the library database',
        description:
            'Take the supplied unnormalized schema and bring it to third normal '
            'form. Explain each change and include the final SQL schema.',
        dueDate: _daysFrom(now, 6, 17, 0),
        type: TaskType.lab,
      ),
      CampusTask(
        id: 4,
        courseId: 1,
        courseName: 'Mobile Application Development',
        studentId: 7,
        title: 'State management reflection',
        description:
            'Write a short reflection comparing setState, InheritedWidget, and '
            'ChangeNotifier for a medium-sized Flutter application.',
        dueDate: _daysFrom(now, -3, 23, 59),
        status: TaskStatus.submitted,
        type: TaskType.assignment,
      ),
      CampusTask(
        id: 5,
        courseId: 3,
        courseName: 'Database Systems',
        studentId: 7,
        title: 'Campus ER diagram',
        description:
            'Model the main entities of a university system and their '
            'relationships, then convert the diagram into relational tables.',
        dueDate: _daysFrom(now, -7, 17, 0),
        status: TaskStatus.completed,
        type: TaskType.project,
      ),
      CampusTask(
        id: 6,
        courseId: 2,
        courseName: 'Computer Networks',
        studentId: 7,
        title: 'Packet analysis lab',
        description:
            'Capture and analyze a short network session. Identify the '
            'protocols in use and describe what each packet reveals.',
        dueDate: _daysFrom(now, -10, 23, 59),
        type: TaskType.lab,
        canSubmit: false,
      ),
    ]);

    events.addAll([
      CampusEvent(
        id: 1,
        title: 'Library orientation tour',
        description:
            'A guided tour of the main library for new and returning students. '
            'Learn how to borrow books, reserve study rooms, and use the online '
            'research databases.',
        start: _daysFrom(now, 1, 11, 0),
        end: _daysFrom(now, 1, 12, 0),
        location: 'Main Library',
        category: EventCategory.campus,
        organizer: 'Library Services',
      ),
      CampusEvent(
        id: 2,
        title: 'Cyber security seminar',
        description:
            'Industry speakers discuss practical threats, secure coding, and '
            'career paths in cyber security. There will be time for questions '
            'and networking after the talks.',
        start: _daysFrom(now, 3, 10, 0),
        end: _daysFrom(now, 3, 12, 0),
        location: 'Main Auditorium',
        category: EventCategory.academic,
        organizer: 'Faculty of Computing & IT',
      ),
      CampusEvent(
        id: 3,
        title: 'Student project exhibition',
        description:
            'Final-year students present their software, engineering, and '
            'business projects. Visitors can meet the teams and vote for the '
            'People\'s Choice award.',
        start: _daysFrom(now, 7, 9, 0),
        end: _daysFrom(now, 7, 15, 0),
        location: 'Innovation Hub',
        category: EventCategory.academic,
        organizer: 'Student Affairs',
      ),
      CampusEvent(
        id: 4,
        title: 'Inter-faculty football tournament',
        description:
            'Cheer for your faculty team in the opening matches of the annual '
            'tournament. Refreshments will be available at the sports ground.',
        start: _daysFrom(now, 10, 15, 0),
        end: _daysFrom(now, 10, 17, 0),
        location: 'Sports Ground',
        category: EventCategory.sports,
        organizer: 'Sports Office',
      ),
      CampusEvent(
        id: 5,
        title: 'Campus career fair',
        description:
            'Meet recruiters from technology, engineering, finance, and '
            'education organizations. Bring copies of your CV and dress '
            'professionally.',
        start: _daysFrom(now, 14, 9, 0),
        end: _daysFrom(now, 14, 16, 0),
        location: 'Main Hall',
        category: EventCategory.career,
        organizer: 'Career Services',
      ),
      CampusEvent(
        id: 6,
        title: 'Cultural night',
        description:
            'An evening of music, poetry, food, and performances organized by '
            'student cultural associations. Open to all students and staff.',
        start: _daysFrom(now, 18, 18, 0),
        end: _daysFrom(now, 18, 21, 0),
        location: 'Open Amphitheatre',
        category: EventCategory.cultural,
        organizer: 'Student Cultural Association',
      ),
    ]);

    announcements.addAll([
      Announcement(
        id: 1,
        title: 'Midterm examination timetable released',
        message:
            'The midterm examination timetable is now available on the student '
            'portal. Please check your personalized schedule carefully and '
            'report any clashes to the Examinations Office within three working '
            'days. Bring your university ID to every examination.',
        publishedAt: _daysAgo(now, 1),
        author: 'Examinations Office',
        category: AnnouncementCategory.academic,
        isImportant: true,
      ),
      Announcement(
        id: 2,
        title: 'New library opening hours',
        message:
            'From this week, the main library is open from 08:00 to 22:00 on '
            'weekdays and from 10:00 to 18:00 on Saturdays. The quiet study '
            'floor remains open until 23:00 during the examination period.',
        publishedAt: _daysAgo(now, 2),
        author: 'Library Services',
        category: AnnouncementCategory.campus,
      ),
      Announcement(
        id: 3,
        title: 'Tuition payment reminder',
        message:
            'Students with outstanding tuition balances should complete payment '
            'before the end of the month. Payment plans are available at the '
            'Finance Office for students who need support. Bring your student ID '
            'when visiting the office.',
        publishedAt: _daysAgo(now, 3),
        author: 'Finance Office',
        category: AnnouncementCategory.reminder,
        isImportant: true,
      ),
      Announcement(
        id: 4,
        title: 'Google Developer Student Club applications open',
        message:
            'Applications for the Google Developer Student Club are now open. '
            'Join workshops on Flutter, cloud, and machine learning, and work on '
            'projects with other students. No previous experience is required.',
        publishedAt: _daysAgo(now, 4),
        author: 'Career Services',
        category: AnnouncementCategory.opportunity,
      ),
      Announcement(
        id: 5,
        title: 'Campus Wi-Fi maintenance',
        message:
            'The campus Wi-Fi network will be unavailable on Saturday from '
            '01:00 to 04:00 while the IT team upgrades the access points. '
            'Wired connections in the computer labs will remain available.',
        publishedAt: _daysAgo(now, 5),
        author: 'IT Services',
        category: AnnouncementCategory.campus,
      ),
      Announcement(
        id: 6,
        title: 'Merit scholarship applications',
        message:
            'Applications for the merit scholarship are open to students with a '
            'cumulative GPA of 3.5 or above. Submit the application form, your '
            'transcript, and a short statement to the Scholarship Office before '
            'the deadline.',
        publishedAt: _daysAgo(now, 6),
        author: 'Scholarship Office',
        category: AnnouncementCategory.opportunity,
        isImportant: true,
      ),
    ]);
  }

  static DateTime _daysFrom(
    DateTime now,
    int days,
    int hour,
    int minute,
  ) {
    return DateTime(now.year, now.month, now.day, hour, minute)
        .add(Duration(days: days));
  }

  static DateTime _daysAgo(DateTime now, int days) {
    return now.subtract(Duration(days: days));
  }

  void _refreshCounters() {
    _nextUserId = _maxId(users.map((user) => user.id)) + 1;
    _nextStudentId = _maxId(students.map((student) => student.id)) + 1;
    _nextTaskId = _maxId(tasks.map((task) => task.id)) + 1;
    _nextEventId = _maxId(events.map((event) => event.id)) + 1;
    _nextAnnouncementId =
        _maxId(announcements.map((announcement) => announcement.id)) + 1;
  }

  static int _maxId(Iterable<int> ids) {
    var highest = 0;
    for (final id in ids) {
      if (id > highest) highest = id;
    }
    return highest;
  }
}
