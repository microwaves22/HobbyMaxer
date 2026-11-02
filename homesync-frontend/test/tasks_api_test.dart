import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:homesync/core/network/api_client.dart';
import 'package:homesync/views/tasks/models/chore_task.dart';
import 'package:homesync/views/tasks/tasks_api.dart';
import 'package:homesync/views/tasks/tasks_controller.dart';

Map<String, dynamic> _task({
  required int id,
  required String status,
  int? assignee,
  bool requiresPhoto = false,
  int points = 10,
}) {
  return {
    'id': id,
    'family_id': 2,
    'title': 'Task $id',
    'description': 'Details $id',
    'task_type': 'chore',
    'points_reward': points,
    'requires_photo': requiresPhoto,
    'assigned_to_user_id': assignee,
    'status': status,
    'due_date': null,
    'created_at': '2026-01-01T00:00:00',
  };
}

Map<String, dynamic> _submission({
  required int id,
  required int taskId,
  required String status,
  int? submittedBy,
  String? photoPath,
}) {
  return {
    'id': id,
    'task_id': taskId,
    'submitted_by_user_id': submittedBy,
    'status': status,
    'photo_path': photoPath,
    'note': null,
    'expires_at': null,
    'reviewed_at': null,
    'created_at': '2026-01-01T00:00:00',
  };
}

Map<String, dynamic> _member({
  required int id,
  required String name,
  required String role,
  int balance = 0,
}) {
  return {
    'id': id,
    'family_id': 2,
    'email': null,
    'display_name': name,
    'role': role,
    'mode': role == 'child' ? 'kids' : null,
    'points_balance': balance,
    'created_at': '2026-01-01T00:00:00',
  };
}

MockClient _mock({bool forbidFamily = false}) {
  return MockClient((request) async {
    http.Response json(Object body, [int status = 200]) =>
        http.Response(jsonEncode(body), status);
    final path = request.url.path;
    if (request.method == 'GET' && path == '/tasks/') {
      return json([
        _task(id: 7, status: 'pending_review', assignee: 10, requiresPhoto: true),
        _task(id: 8, status: 'open', assignee: 11),
        _task(id: 9, status: 'approved', assignee: 10),
      ]);
    }
    if (request.method == 'GET' && path == '/families/me') {
      if (forbidFamily) {
        return json({'detail': 'Parents only.'}, 403);
      }
      return json({
        'id': 2,
        'name': 'Fam',
        'created_at': '2026-01-01T00:00:00',
        'members': [
          _member(id: 9, name: 'Mom', role: 'parent'),
          _member(id: 10, name: 'Maya', role: 'child', balance: 120),
          _member(id: 11, name: 'Leo', role: 'child', balance: 45),
        ],
      });
    }
    if (request.method == 'GET' && path == '/tasks/7/submissions') {
      return json([
        _submission(
          id: 1,
          taskId: 7,
          status: 'pending',
          submittedBy: 10,
          photoPath: 'task_7_ab.jpg',
        ),
      ]);
    }
    if (request.method == 'GET' && path == '/tasks/8/submissions') {
      return json([
        _submission(id: 2, taskId: 8, status: 'changes_requested'),
      ]);
    }
    if (request.method == 'POST' && path == '/tasks/8/submit') {
      return json(
        _submission(id: 3, taskId: 8, status: 'pending', submittedBy: 11),
        201,
      );
    }
    if (request.method == 'PUT' && path == '/tasks/7/approve') {
      return json(
        _submission(id: 1, taskId: 7, status: 'approved', submittedBy: 10),
      );
    }
    return http.Response('not found', 404);
  });
}

void main() {
  group('TasksApi + synced controller', () {
    test('fetchSnapshot maps tasks, names, photos, and balances', () async {
      final api = TasksApi(ApiClient(inner: _mock()));

      final snapshot = await api.fetchSnapshot();

      expect(snapshot.tasks.length, 3);
      final reviewing = snapshot.tasks.firstWhere((t) => t.id == 'srv-7');
      expect(reviewing.serverId, 7);
      expect(reviewing.state, TaskState.pendingReview);
      expect(reviewing.childName, 'Maya');
      expect(reviewing.remotePhoto, 'task_7_ab.jpg');
      final sentBack = snapshot.tasks.firstWhere((t) => t.id == 'srv-8');
      expect(sentBack.state, TaskState.changesRequested);
      expect(
        snapshot.tasks.firstWhere((t) => t.id == 'srv-9').state,
        TaskState.approved,
      );
      expect(snapshot.balances, {'Mom': 0, 'Maya': 120, 'Leo': 45});
    });

    test('children sync tasks without the family roster', () async {
      final api = TasksApi(ApiClient(inner: _mock(forbidFamily: true)));

      final snapshot = await api.fetchSnapshot();

      expect(snapshot.tasks.length, 3);
      expect(snapshot.balances, isEmpty);
      expect(snapshot.tasks.first.childName, 'Unassigned');
    });

    test('controller submit/approve round-trip keeps the ledger exact',
        () async {
      final controller = TasksController.test();
      controller.attachBackend(TasksApi(ApiClient(inner: _mock())));
      await controller.refresh();

      await controller.submitPhoto('srv-8', null);
      expect(
        controller.byId('srv-8')!.state,
        TaskState.pendingReview,
      );

      await controller.approve('srv-7');
      expect(controller.byId('srv-7')!.state, TaskState.approved);
      expect(controller.balanceFor('Maya'), 130);
    });
  });
}
