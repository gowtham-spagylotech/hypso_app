import 'package:flutter/material.dart';
import 'package:hypso/utils/utils.dart';

class HomeSearchBar extends StatefulWidget {
  final VoidCallback onSearch;

  const HomeSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _HomeSearchBarState createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).dividerColor.withOpacity(.06),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  hintText: Translate.of(context).translate('search_text'),
                  hintStyle: Theme.of(context).textTheme.labelLarge,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // You can access the typed value using the _searchController.text
                  // Do something with the value here
                },
              ),
            ),
            Container(
              height: double.infinity,
              child: const VerticalDivider(),
            ),
            // InkWell for adding a ripple effect on tap
            InkWell(
              onTap: widget.onSearch, // Use the provided onSearch callback
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Icon(
                  Icons.saved_search,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
