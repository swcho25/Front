import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../models/user_profile.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final Future<UserProfile?> Function(String) getUserProfile;

  const GroupCard({
    Key? key,
    required this.group,
    required this.getUserProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(group.description),
            SizedBox(height: 8),
            _buildMembersRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersRow() {
    return FutureBuilder<List<UserProfile?>>(
      future: Future.wait(
        group.members.map((userId) => getUserProfile(userId)),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final users = snapshot.data!
            .where((user) => user != null)
            .cast<UserProfile>()
            .toList();
        int maxVisibleMembers = 3;
        List<UserProfile> visibleUsers = users.take(maxVisibleMembers).toList();
        int remainingMembers = users.length - maxVisibleMembers;

        return Row(
          children: [
            ...visibleUsers.map((user) => _buildMemberAvatar(user)).toList(),
            if (remainingMembers > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('외 $remainingMembers명'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMemberAvatar(UserProfile user) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: user.profileImage.isNotEmpty
                ? NetworkImage(user.profileImage)
                : null,
            child: user.profileImage.isEmpty ? Icon(Icons.person) : null,
          ),
          SizedBox(width: 4),
          Container(
            width: 50,
            child: Text(
              user.nickname,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}