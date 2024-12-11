// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:pjpacktrack/modules/ui/play_video.dart';
// import 'build_process_step.dart';
//
// class OrderProcessScreen extends StatelessWidget {
//   final Map<String, dynamic> orderData;
//   final Map<String, dynamic> videoData;
//   final String orderDate;
//   final String userId;
//
//   const OrderProcessScreen({
//     super.key,
//     required this.orderData,
//     required this.videoData,
//     required this.orderDate,
//     required this.userId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Quy trình đơn hàng'),
//           backgroundColor: Colors.teal,
//           elevation: 0,
//           bottom: TabBar(
//             tabs: [
//               Tab(
//                 icon: Icon(Icons.inventory_2, color: Colors.blue),
//                 text: 'Đóng gói',
//               ),
//               Tab(
//                 icon: Icon(Icons.local_shipping, color: Colors.green),
//                 text: 'Giao hàng',
//               ),
//               Tab(
//                 icon: Icon(Icons.assignment_return, color: Colors.orange),
//                 text: 'Trả hàng',
//               ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             _buildOrderInfo(),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   _buildDeliveryTab('Đóng gói', Icons.inventory_2, Colors.blue),
//                   _buildDeliveryTab(
//                       'Giao hàng', Icons.local_shipping, Colors.green),
//                   _buildDeliveryTab(
//                       'Trả hàng', Icons.assignment_return, Colors.orange),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDeliveryTab(String title, IconData icon, Color color) {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         ProcessStepWidget(
//           title: title,
//           icon: icon,
//           color: color,
//           isActive: _getStatusForStep(title),
//           orderData: {...orderData, 'currentStep': title},
//           userId: userId,
//         ),
//         const Divider(height: 32),
//         _buildVideoList(title),
//       ],
//     );
//   }
//
//   Widget _buildVideoList(String deliveryOption) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('orders')
//           .doc(orderData['id'])
//           .collection('videos')
//           .where('deliveryOption', isEqualTo: deliveryOption)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.videocam_off, size: 48, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Chưa có video cho $deliveryOption',
//                   style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final videos = snapshot.data!.docs;
//
//         String formatDate(DateTime date) {
//           return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
//         }
//
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: videos.length,
//           itemBuilder: (context, index) {
//             final video = videos[index].data() as Map<String, dynamic>;
//             final uploadDate = (video['uploadDate'] as Timestamp).toDate();
//
//             return Dismissible(
//               key: Key(video['fileName']),
//               background: Container(
//                 color: Colors.red.shade400,
//                 alignment: Alignment.centerRight,
//                 child: const Padding(
//                   padding: EdgeInsets.only(right: 16),
//                   child:
//                       Icon(Icons.delete_forever, color: Colors.white, size: 32),
//                 ),
//               ),
//               direction: DismissDirection.endToStart,
//               confirmDismiss: (direction) => _showDeleteConfirmation(context),
//               onDismissed: (_) => _deleteVideo(
//                 orderData['id'],
//                 videos[index].id as bool,
//                 video['url'],
//                 userId,
//                 orderData['isQRCode'],
//               ),
//               child: Card(
//                 elevation: 2,
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: InkWell(
//                   onTap: () => _openVideo(context, video),
//                   borderRadius: BorderRadius.circular(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: 64,
//                           height: 64,
//                           decoration: BoxDecoration(
//                             color: Colors.black87,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.play_circle_fill,
//                             color: Colors.white,
//                             size: 32,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 video['fileName'] ?? 'Video',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Ngày tải lên: ${formatDate(uploadDate)}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.chevron_right, color: Colors.grey[400]),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _openVideo(BuildContext context, Map<String, dynamic> video) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AwsVideoPlayer(
//           orderId: orderData['id'],
//           deliveryOption: video['deliveryOption'],
//           fileName: video['fileName'],
//         ),
//       ),
//     );
//   }
//
//   bool _getStatusForStep(String step) {
//     switch (step) {
//       case 'Đóng gói':
//         return orderData['closedStatus'] ?? false;
//       case 'Giao hàng':
//         return orderData['shippingStatus'] ?? false;
//       case 'Trả hàng':
//         return orderData['returnStatus'] ?? false;
//       default:
//         return false;
//     }
//   }
//
//   Future<bool> _showDeleteConfirmation(BuildContext context) async {
//     return await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Xóa video'),
//             content: const Text('Bạn có chắc chắn muốn xóa video này không?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Hủy'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text('Xóa', style: TextStyle(color: Colors.red)),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }
//
//   Future<void> _deleteVideo(String docId, bool isQRCode, String videoId,
//       String videoUrl, String userId) async {
//     try {
//       final docRef = FirebaseFirestore.instance.collection('orders').doc(docId);
//
//       // Verify userId before deleting
//       final doc = await docRef.get();
//       if (doc.exists && doc.data()?['userId'] == userId) {
//         await docRef.collection('videos').doc(videoId).delete();
//       }
//     } catch (e) {
//       print('Error deleting video: $e');
//     }
//   }
//
//   Widget _buildOrderInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.teal.withOpacity(0.1),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.info_outline, color: Colors.teal),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${orderData['isQRCode'] ? "Mã đơn hàng" : "Mã đơn hàng"}: ${orderData['id']}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Ngày tạo: $orderDate',
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
