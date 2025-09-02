import 'package:flutter/material.dart';

class RateAndComment extends StatefulWidget {
  final String placeId;
  const RateAndComment({super.key, required this.placeId});

  @override
  State<RateAndComment> createState() => _RateAndCommentState();
}

class _RateAndCommentState extends State<RateAndComment> {
  int rating = 0;
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate this place'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Post", style: TextStyle(color: Colors.blue[800])),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                CircleAvatar(
                  radius:25 ,
                  backgroundColor: Colors.blue[900],
                  child: Text('P', style: TextStyle(color: Colors.white,
                  fontSize: 22),
                  ),
                ),
                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Title/Person's name
                      Text('Person 1', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),

                      Text(
                        'Review are public and include your account.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Center(
              child: Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 32,
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon:Icon(index< rating?  Icons.star : Icons.star_border,
                    color: index< rating ?Colors.amber: null,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: commentController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Describe your experience (optional)',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                
                border: OutlineInputBorder(

                  
                ),
                // counterText: '${commentController.text.length}/500'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
