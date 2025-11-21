import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onIndexChanged;
  const DashboardPage({super.key, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: Padding(
        padding: EdgeInsets.all(30.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            SizedBox(height: 24),
            
            // Quick Stats
            Center(child: _buildQuickStats()),
            SizedBox(height: 24),
            
            // Recent Activity
            Expanded(
              child: _buildRecentActivity(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.business, color: Colors.blue[700], size: 30),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your hostels and track performance',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Wrap(
  spacing: 30.w,
  runSpacing: 20.w,
  children: [
    _buildStatCard('Total Hostels', '5', Icons.business, Colors.blue),
    _buildStatCard('Active Bookings', '12', Icons.calendar_today, Colors.green),
    _buildStatCard('Pending Requests', '3', Icons.pending_actions, Colors.orange),
    _buildStatCard('Total Earnings', 'GHS 400.00', Icons.attach_money, Colors.purple),
  ],
);

  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding:  EdgeInsets.all(60.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              _buildActivityItem('New booking received', '2 hours ago', Icons.bookmark, Colors.green),
              _buildActivityItem('Payment received', '5 hours ago', Icons.payment, Colors.blue),
              _buildActivityItem('Hostel review added', '1 day ago', Icons.star, Colors.orange),
              _buildActivityItem('Booking cancelled', '2 days ago', Icons.cancel, Colors.red),
              _buildActivityItem('New hostel added', '3 days ago', Icons.business, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(time),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}