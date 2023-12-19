import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypso/blocs/bloc.dart';
import 'package:hypso/configs/config.dart';
import 'package:hypso/models/model.dart';
import 'package:hypso/screens/home/home_category_item.dart';
import 'package:hypso/screens/home/home_sliver_app_bar.dart';
import 'package:hypso/utils/utils.dart';
import 'package:hypso/widgets/widget.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  late StreamSubscription _submitSubscription;
  late StreamSubscription _reviewSubscription;

  @override
  void initState() {
    super.initState();
    AppBloc.homeCubit.onLoad();
    _submitSubscription = AppBloc.submitCubit.stream.listen((state) {
      if (state is Submitted) {
        AppBloc.homeCubit.onLoad();
      }
    });
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewSuccess && state.id != null) {
        AppBloc.homeCubit.onLoad();
      }
    });
  }

  @override
  void dispose() {
    _submitSubscription.cancel();
    _reviewSubscription.cancel();
    super.dispose();
  }

  ///Refresh
  Future<void> _onRefresh() async {
    await AppBloc.homeCubit.onLoad();
  }

  ///On search
  void _onSearch() {
    // Navigator.pushNamed(context, Routes.searchHistory);
  }

  ///On select category
  void _onCategory(CategoryModel item) {
    if (item.id == -1) {
      Navigator.pushNamed(context, Routes.category);
      return;
    }
    if (item.hasChild) {
      Navigator.pushNamed(context, Routes.category, arguments: item);
    } else {
      Navigator.pushNamed(context, Routes.listProduct, arguments: item);
    }
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item);
  }

  ///Build category UI
  Widget _buildCategory(List<CategoryModel>? category) {
    ///Loading
    Widget content = Wrap(
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(8, (index) => index).map(
        (item) {
          return const HomeCategoryItem();
        },
      ).toList(),
    );

    if (category != null) {
      List<CategoryModel> listBuild = category;
      final more = CategoryModel.fromJson({
        "term_id": -1,
        "name": Translate.of(context).translate("more"),
        "icon": "fas fa-ellipsis",
        "color": "#ff8a65",
      });

      if (category.length >= 7) {
        listBuild = category.take(7).toList();
        listBuild.add(more);
      }

      content = Wrap(
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: listBuild.map(
          (item) {
            return HomeCategoryItem(
              item: item,
              onPressed: _onCategory,
            );
          },
        ).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }

  ///Build list recent
  Widget _buildRecent(List<ProductModel>? recent) {
    ///Loading
    Widget content = ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: AppProductItem(type: ProductViewType.small),
        );
      },
      itemCount: 8,
    );

    if (recent != null) {
      content = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = recent[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AppProductItem(
              onPressed: () {
                _onProductDetail(item);
              },
              item: item,
              type: ProductViewType.small,
            ),
          );
        },
        itemCount: recent.length,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate('recent_location'),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                Translate.of(context).translate(
                  'what_happen',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Map<String, dynamic> homeSwipeData = {
    "images": [
      "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1",
      "https://img.freepik.com/free-photo/full-length-portrait-happy-family_171337-2281.jpg?w=900&t=st=1702967962~exp=1702968562~hmac=73b16dfda6fdbea6c771768547ad04062e2f5bd88642651b19a5531a0460759d",
      "https://img.freepik.com/free-photo/just-look-there-there-is-exactly-what-we-were-looking_329181-1731.jpg?w=360&t=st=1702967973~exp=1702968573~hmac=024c3c467cb9b47be438eff83a99354823493644f07f9a256efe3b08cff503bd",
      "https://img.freepik.com/free-photo/happy-beautiful-couple-posing-with-shopping-bags-violet_496169-2215.jpg?w=900&t=st=1702967977~exp=1702968577~hmac=c8a41113b9f812296a82405efcc10f9338e3809294dacfa19f9e5daeeee951c8",
      "https://img.freepik.com/free-photo/young-female-sitting-shopping-cart_651396-210.jpg?w=360&t=st=1702968027~exp=1702968627~hmac=41114a27b5632dc5043eaebdd20698bdf6969175e3b8b5c0afdca3c62efc1aa9"
    ]
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> jsonData = [
      {
        "id": 1,
        "name": "Category 1",
        "count": 10,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon1",
        "color": "#abcdef",
        "type": "category",
        "hasChild": false
      },
      {
        "id": 2,
        "name": "Category 2",
        "count": 15,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon2",
        "color": "#123456",
        "type": "category",
        "hasChild": true
      },
      {
        "id": 3,
        "name": "Category 3",
        "count": 20,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon3",
        "color": "#789012",
        "type": "category",
        "hasChild": false
      },
      {
        "id": 4,
        "name": "Category 4",
        "count": 12,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon4",
        "color": "#345678",
        "type": "category",
        "hasChild": true
      },
      {
        "id": 5,
        "name": "Category 5",
        "count": 8,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon5",
        "color": "#901234",
        "type": "category",
        "hasChild": false
      },
      {
        "id": 6,
        "name": "Category 6",
        "count": 5,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon6",
        "color": "#567890",
        "type": "category",
        "hasChild": true
      },
      {
        "id": 7,
        "name": "Category 7",
        "count": 18,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon7",
        "color": "#012345",
        "type": "category",
        "hasChild": false
      },
      {
        "id": 8,
        "name": "Category 8",
        "count": 22,
        "image": {
          "id": 0,
          "full": {},
          "thumb": {
            "url":
                "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
          }
        },
        "icon": "icon8",
        "color": "#678901",
        "type": "category",
        "hasChild": true
      }
    ];
    
     List<Map<String, dynamic>> sampleList = [
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  },
  {
    "ID": 123,
    "post_title": "Sample",
    "image": {
      "id": 0,
      "full": {},
      "thumb": {
        "url": "https://img.freepik.com/free-photo/woman-casual-white-sweater-sunglasses-red-wall_343596-5382.jpg?w=900&t=st=1702967923~exp=1702968523~hmac=761f01240364321b2ad3d1c5377024c1a4369f5616fb9c016607bd8bdcbe44f1"
      }
    },
    "video_url": "https://www.example.com/sample-video",
    "category": {
      "id": 1,
      "name": "Sample Category"
    },
    "createDate": "2023-01-01",
    "date_establish": "2023-01-01",
    "rating_avg": 4.5,
    "rating_count": 100,
    "post_status": "Published",
    "wishlist": true,
    "address": "123 Main Street",
    "zip_code": "12345",
    "phone": "123-456-7890",
    "fax": "123-456-7891",
    "email": "info@example.com",
    "website": "https://www.example.com",
    "post_excerpt": "Product description goes here.",
    "color": "#00ff00",
    "icon": "https://www.example.com/icon.png",
    "tags": [
      {
        "id": 2,
        "name": "Tag1"
      },
      {
        "id": 3,
        "name": "Tag2"
      }
    ],
    "price": "50.00",
    "priceMin": "40.00",
    "priceMax": "60.00",
    "country": {
      "id": 4,
      "name": "Sample Country"
    },
    "state": {
      "id": 5,
      "name": "Sample State"
    },
    "city": {
      "id": 6,
      "name": "Sample City"
    },
    "author": {
      "id": 7,
      "name": "John Doe"
    },
    "galleries": [
      {
        "id": 8,
        "full": {},
        "thumb": {}
      },
      {
        "id": 9,
        "full": {},
        "thumb": {}
      }
    ],
    "features": [
      {
        "id": 10,
        "name": "Feature1"
      },
      {
        "id": 11,
        "name": "Feature2"
      }
    ],
    "related": [
      {
        "ID": 12,
        "post_title": "Related Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 13,
        "post_title": "Related Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "latest": [
      {
        "ID": 14,
        "post_title": "Latest Product 1",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      },
      {
        "ID": 15,
        "post_title": "Latest Product 2",
        "image": {
          "id": 0,
          "full": {},
          "thumb": {}
        }
      }
    ],
    "opening_hour": [
      {
        "day": "Monday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      },
      {
        "day": "Tuesday",
        "open": "09:00 AM",
        "close": "06:00 PM"
      }
    ],
    "tags": [
      {
        "id": 16,
        "name": "Tag3"
      },
      {
        "id": 17,
        "name": "Tag4"
      }
    ],
    "attachments": [
      {
        "id": 18,
        "url": "https://www.example.com/attachment1.pdf"
      },
      {
        "id": 19,
        "url": "https://www.example.com/attachment2.pdf"
      }
    ],
    "social_network": {
      "facebook": "https://www.facebook.com/example",
      "twitter": "https://www.twitter.com/example"
    },
    "booking_use": true,
    "booking_style": "style1",
    "booking_price_display": "Starting from 50.00"
  }
];

    List<CategoryModel> categories = jsonData
        .map<CategoryModel>((json) => CategoryModel.fromJson(json))
        .toList();

    List<ProductModel> list = jsonData
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();

    return Scaffold(
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          List<String>? banner;
          List<CategoryModel>? category;
          List<ProductModel>? recent;

          if (state is HomeSuccess) {
            banner = state.banner;
            category = state.category;
            recent = state.recent;
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              SliverPersistentHeader(
                delegate: AppBarHomeSliver(
                    expandedHeight: MediaQuery.of(context).size.height * 0.3,
                    banners: List<String>.from(homeSwipeData['images']),
                    onSearch: _onSearch),
                pinned: true,
              ),
              CupertinoSliverRefreshControl(
                onRefresh: _onRefresh,
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(
                      children: <Widget>[
                        _buildCategory(categories),
                        const SizedBox(height: 8),
                        _buildRecent(list),
                        const SizedBox(height: 28),
                      ],
                    ),
                  )
                ]),
              )
            ],
          );
        },
      ),
    );
  }
}
