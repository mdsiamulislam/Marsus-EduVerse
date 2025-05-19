import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/list_of_content.dart';

class Blogtab extends StatefulWidget {
  const Blogtab({super.key});

  @override
  State<Blogtab> createState() => _BlogtabState();
}

class _BlogtabState extends State<Blogtab> {
  String selectedTag = 'All';

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the blog link.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  List<String> getAllTags() {
    final tags = BlogList.map((e) => e['tag'].toString()).toSet().toList();
    tags.sort();
    return ['All', ...tags];
  }

  List<Map<String, dynamic>> getFilteredBlogs() {
    if (selectedTag == 'All') return BlogList;
    return BlogList.where((blog) => blog['tag'] == selectedTag).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBlogs = getFilteredBlogs();
    final tags = getAllTags();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blogs'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tag Filter Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = tag == selectedTag;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedTag = tag;
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Blog List
          Expanded(
            child: filteredBlogs.isEmpty
                ? const Center(
              child: Text(
                'No blogs found for this tag.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredBlogs.length,
              itemBuilder: (context, index) {
                final blog = filteredBlogs[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          blog['image'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/blogplaceholder.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Image.asset(
                              'assets/img.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTag = blog['tag'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Text(
                                  blog['tag'],
                                  style: const TextStyle(color: Colors.green, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              blog['description'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(onPressed: () {
                                final link = blog['link'];
                                if (link != null && link.toString().startsWith('http')) {
                                  _launchURL(link);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invalid or missing blog link.')),
                                  );
                                }
                              },
                                icon: const Icon(Icons.open_in_new, color: Colors.white),
                                label: const Text('Read More'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
