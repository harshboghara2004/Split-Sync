import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitsync/Database/group_data.dart';
import 'package:splitsync/Database/group_transaction.dart';
import 'package:splitsync/Models/group.dart';
import 'package:splitsync/Models/group_transaction.dart';
import 'package:splitsync/Models/user.dart';
import 'package:splitsync/Widgets/checkbox_card.dart';
import 'package:splitsync/utils/user_provider.dart';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({
    super.key,
    required this.group,
    required this.total,
    required this.desc,
  });

  final Group group;
  final double total;
  final String desc;

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final TextEditingController _newAmountController = TextEditingController();
  bool _first = true;
  User? currentUser;


  List<String> _selectedMembers = [];
  List<String> _editedMembers = [];
  Map<String, double> distribution = {};

  void _editAmount(BuildContext context, User member) {
    // Show dialog or navigate to another screen for editing amount
    _newAmountController.text = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Amount for ${member.username}'),
          content: TextFormField(
            controller: _newAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'New Amount'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final newVal = double.parse(_newAmountController.text);
                final newDist = await GroupTxsData().changeAmountOfMember(
                  selectedMembers: _selectedMembers,
                  editedMembers: _editedMembers,
                  dist: distribution,
                  memKey: member.username,
                  total: widget.total,
                  newAmt: newVal,
                );
                _editedMembers.add(member.username);
                setState(() {
                  distribution = newDist;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _firstTime() async {
    _selectedMembers = [currentUser!.username];
    final dist = await GroupTxsData().createDistribution(
      amount: widget.total,
      selectedMembers: _selectedMembers,
    );
    distribution = dist;
    _first = false;
  }

  _fetchData() async {
    if (_first) await _firstTime();
    final members = await GroupData().getAllMembers(key: widget.group.key!);
    // print('success');
    return members;
  }

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserProvider>(context).currentUser;

    return FutureBuilder(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('No Members'),
          );
        }
        final groupMembers = snapshot.data as List<User>;
        // return Center(child: const Text('test'),);
        return Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 4),
                    ),
                    itemCount: groupMembers.length,
                    itemBuilder: (context, index) {
                      final member = groupMembers[index];
                      final isSelected =
                          _selectedMembers.contains(member.username);
                      return CheckboxCard(
                        title: member.username,
                        value: isSelected,
                        amount: distribution[member.username] ?? 0.0,
                        onEdit: () {
                          _editAmount(context, member);
                        },
                        onChanged: (value) async {
                          Map<String, double> newDist = {};
                          if (value != null && value) {
                            newDist =
                                await GroupTxsData().addMemberToDistribution(
                              selectedMembers: _selectedMembers,
                              editedMembers: _editedMembers,
                              total: widget.total,
                              member: groupMembers[index].username,
                              dist: distribution,
                            );
                          } else {
                            newDist =
                                await GroupTxsData().removeMemberToDistribution(
                              selectedMembers: _selectedMembers,
                              editedMembers: _editedMembers,
                              total: widget.total,
                              member: groupMembers[index].username,
                              dist: distribution,
                            );
                          }
                          // print(newDist);
                          setState(() {
                            if (value != null && value) {
                              _selectedMembers.add(member.username);
                              distribution = newDist;
                            } else {
                              if (_selectedMembers.length > 1 &&
                                  distribution != newDist) {
                                _selectedMembers.remove(member.username);
                                if (_editedMembers.contains(member.username)) {
                                  _editedMembers.remove(member.username);
                                }
                              }
                              distribution = newDist;
                            }
                            newDist.forEach((key, value) {
                              if (value == 0.0) {
                                _selectedMembers.remove(key);
                                if (_editedMembers.contains(member.username)) {
                                  _editedMembers.remove(member.username);
                                }
                              }
                            });
                          });
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.only(bottom: 5),
                  child: ElevatedButton(
                    onPressed: () async {
                      // print(distribution);
                      final gtx = GroupTransaction(
                        groupKey: widget.group.key!,
                        amount: widget.total,
                        creator: currentUser!.username,
                        description: widget.desc,
                        distribution: distribution,
                      );
                      // ignore: unused_local_variable
                      final res = await GroupTxsData().addGroupTransaction(gtx: gtx);
                      // print(res);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
