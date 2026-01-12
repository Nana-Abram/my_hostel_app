import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_network/image_network.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/auth_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/auth/login.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/add_hostels_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/edit_hostel_page.dart';
import 'package:my_hostel_app/ui/dashboard/hostel_owner_dashboard/view_hostel_page.dart';


class MyHostelsPage extends ConsumerStatefulWidget {
  const MyHostelsPage({super.key});

  @override
  ConsumerState<MyHostelsPage> createState() => _MyHostelsPageState();
}

class _MyHostelsPageState extends ConsumerState<MyHostelsPage> {
  @override
  Widget build(BuildContext context) {
  
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => Scaffold(
       
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
      
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Authentication Error: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(authProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (user) {
        // User is not signed in
        if (user == null) {
          return _buildNotSignedInState();
        }

        // User is signed in - get their hostels
        final currentUserId = user.id;
        final hostelsAsync = ref.watch(hostelsByOwnerProvider(currentUserId));

        return Scaffold(
          body: hostelsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // ignore: unused_result
                      ref.refresh(hostelsByOwnerProvider(currentUserId));
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (hostels) {
              if (hostels.isEmpty) {
                return _buildEmptyState();
              }
              return _buildHostelsList(hostels);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _onAddHostelPressed(),
            backgroundColor: Colors.blue[700],
            child: Icon(Icons.add),
          ),
        );
      },
    );
  

  }

  
  Widget _buildNotSignedInState() {
    return Scaffold(
   
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Please Sign In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You need to be signed in to view your hostels',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to your login page
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
              ),
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Hostels Added',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first hostel to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _onAddHostelPressed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: Text('Add Hostel'),
          ),
        ],
      ),
    );
  }

  Widget _buildHostelsList(List<HostelModel> hostels) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
      itemCount: hostels.length,
      itemBuilder: (context, index) {
        return _buildHostelCard(hostels[index]);
      },
    );
  }

Widget _buildHostelCard(HostelModel hostel) {
  return Card(
    elevation: 4,
    margin: EdgeInsets.only(bottom: 20.h),
    child: Padding(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hostel Image
  
              SizedBox(
                width: 180.w,
                height: 120.h,
                child: ImageNetwork(
                          image: hostel.images.isNotEmpty ? hostel.images.first : '', 
                          height: 120.h, 
                          width: 180.w,
                          onError: Icon(Icons.business, color: Colors.grey[400], size: 80.w),
                          fitAndroidIos: BoxFit.cover,
                          fitWeb: BoxFitWeb.cover,
                          borderRadius: BorderRadius.circular(8.r),
                          backgroundColor: Colors.blue[50],
                          ),
              ),
  
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostel.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${hostel.campus} • ${hostel.location}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text(
                          hostel.campus,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.room, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hostel.location,
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Rating and Price Row
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                hostel.rating.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Text(
                '(${hostel.reviewsCount.toInt()} reviews)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.attach_money, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text(
                'Starts at GHS ${hostel.startPrice.toInt()}/year',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Rooms and Status
          Row(
            children: [
              Icon(Icons.meeting_room, color: Colors.purple, size: 16),
              SizedBox(width: 4),
              Text(
                '${hostel.totalRooms.toInt()} Rooms',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.apartment, color: Colors.orange, size: 16),
              SizedBox(width: 4),
              Text(
                '${hostel.amenities.length} Amenities',
                style: TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(hostel.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(hostel.status),
                  ),
                ),
                child: Text(
                  hostel.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(hostel.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit'),
                  onPressed: () => _onEditHostelPressed(hostel),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('View'),
                  onPressed: () => _onViewHostelPressed(hostel),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Delete'),
                  onPressed: () => _onDeleteHostelPressed(hostel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _onAddHostelPressed() {
      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AddHostelPage()),
  );
  }

void _onEditHostelPressed(HostelModel hostel) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditHostelPage(hostel: hostel,),), // Example: Edit the first room
    
  );
}

void _onViewHostelPressed(HostelModel hostel) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewHostelPage(hostel: hostel),
    ),
  );
}

void _onDeleteHostelPressed(HostelModel hostel) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Hostel'),
      content: Text('Are you sure you want to delete "${hostel.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),

ElevatedButton(
  onPressed: () async {
    Navigator.pop(context); // Close the dialog first
    
    // Store context in a local variable before any async operations
    final scaffoldContext = context;
    
    try {
      final service = ref.read(hostelServiceProvider);
      await service.deleteHostel(hostel.id);
      
      // Use the stored context to show SnackBar
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(content: Text('Hostel deleted successfully')),
        );
      }
      
    } catch (e) {
      // Use the stored context to show error SnackBar
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(content: Text('Failed to delete hostel: $e')),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: Text('Delete'),
),

      ],
    ),
  );
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}