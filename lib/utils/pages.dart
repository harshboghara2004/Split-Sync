import 'package:flutter/material.dart';
import 'package:splitsync/Screens/Friends/friends_screen.dart';
import 'package:splitsync/Screens/Groups/group_screen.dart';
import 'package:splitsync/Screens/Profile/profile_screen.dart';
import 'package:splitsync/Screens/Search/search_screen.dart';

List<Widget> pages = [
  FriendsScreen(),
  SearchScreen(isInGroup: false,),
  GroupScreen(),
  ProfileScreen(),
];