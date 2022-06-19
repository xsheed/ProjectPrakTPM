import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projek_mealdb/helper/hive_database_fav.dart';
import 'package:projek_mealdb/helper/shared_preference.dart';
import 'package:projek_mealdb/hive_model/myfavorite_model.dart';
import 'package:projek_mealdb/model/meal_detail_model.dart';
import 'package:projek_mealdb/model/meal_list_model.dart';
import 'package:projek_mealdb/source/meal_source.dart';
import 'package:projek_mealdb/view/meal_category.dart';
import 'home_page.dart';
import 'meal_list_page.dart';

class DetailPage extends StatefulWidget {
  final MealList data;
  final String username;
  final int index;
  const DetailPage({Key? key, required this.data, required this.index, required this.username})
      : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int no = widget.index;
  final HiveDatabaseFav _hiveFav = HiveDatabaseFav();
  bool isFavorite = false;

  @override
  void initState() {
    isFavorite = _hiveFav.checkFavorite(
        widget.username,"${widget.data.meals![no].idMeal}");
    debugPrint(widget.username+"dan"+ "$isFavorite");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Detail of ${widget.data.meals?[no].strMeal}".toTitleCase()),
        actions: [
          IconButton(
            onPressed: () {
              if (isFavorite == false) {
                _hiveFav.addData(
                  MyFavorite(
                    name: widget.username,
                    nameMeal: widget.data.meals![no].strMeal,
                    idMeal: widget.data.meals![no].idMeal,
                    imageMeal: widget.data.meals![no].strMealThumb,
                  ),
                );
                setState(() {
                  isFavorite = true;
                });
              } else if (isFavorite == true) {
                _hiveFav.deleteData(widget.username, "${widget.data.meals![no].idMeal}",);
                setState(() {
                  isFavorite = false;
                });
              }
            },
            iconSize: 30,
            icon: (isFavorite == true)
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
          ),
          IconButton(onPressed: () async {
            String username  = await SharedPreference.getUsername();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                    username: username,
                  )),
                  (_) => false,
            );
          }, icon: const Icon(Icons.home), iconSize: 30,)
        ],
      ),
      body: _buildDetailMeal(),
    );
  }

  Widget _buildDetailMeal() {
    debugPrint("${widget.data.meals?[no].idMeal}");
    return FutureBuilder(
        future: MealSource.instance
            .loadDetail(idMeal: "${widget.data.meals?[no].idMeal}"),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return _buildErrorSection();
          }
          if (snapshot.hasData) {
            MealDetail mealdetail = MealDetail.fromJson(snapshot.data);
            return _buildSuccessSection(mealdetail);
          }
          return _buildLoadingSection();
        });
  }

  Widget _buildLoadingSection() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorSection() {
    return const Text("Error2");
  }

  Widget _buildSuccessSection(MealDetail data) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildHeader(data),
            _buildDescription(data),
            _buildIngredient(data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MealDetail data) {
    return Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 5.0, color: Colors.brown),
          borderRadius: BorderRadius.circular(25),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  "${data.meals![0].strMealThumb}",
                  fit: BoxFit.fill,
                  width: 120.0,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 200.0,
              height: 140.0,
              child: Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${data.meals![0].strMeal}".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontSize: 20.0,
                      ),
                    ),
                    Text(
                      "Meal ID. ${data.meals![0].idMeal}",
                      style: TextStyle(fontSize: 18.0, fontFamily: 'Koulen'),
                    ),
                    Text(
                      "Meal Category: ${data.meals![0].strCategory}",
                      style: TextStyle(fontSize: 18.0, fontFamily: 'Koulen'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  Widget _buildDescription(MealDetail data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 9),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 5.0, color: Colors.brown.shade700),
          borderRadius: BorderRadius.circular(20),
          color: Colors.brown.withOpacity(0.6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "INSTRUCTIONS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 20.0,
                  ),
                ),
              ),
              Text(
                "${data.meals![0].strInstructions}",
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredient(MealDetail data) {
    List<String> value = [
      "${data.meals![0].strIngredient1}", "${data.meals![0].strIngredient2}",
      "${data.meals![0].strIngredient3}", "${data.meals![0].strIngredient4}",
      "${data.meals![0].strIngredient5}", "${data.meals![0].strIngredient6}",
      "${data.meals![0].strIngredient7}", "${data.meals![0].strIngredient8}",
      "${data.meals![0].strIngredient9}", "${data.meals![0].strIngredient10}",
      "${data.meals![0].strIngredient11}", "${data.meals![0].strIngredient12}",
      "${data.meals![0].strIngredient13}", "${data.meals![0].strIngredient14}",
      "${data.meals![0].strIngredient15}",
    ];
    List<String> valueMeasure = [
      "${data.meals![0].strMeasure1}", "${data.meals![0].strMeasure2}",
      "${data.meals![0].strMeasure3}", "${data.meals![0].strMeasure4}",
      "${data.meals![0].strMeasure5}", "${data.meals![0].strMeasure6}",
      "${data.meals![0].strMeasure7}", "${data.meals![0].strMeasure8}",
      "${data.meals![0].strMeasure9}", "${data.meals![0].strMeasure10}",
      "${data.meals![0].strMeasure11}", "${data.meals![0].strMeasure12}",
      "${data.meals![0].strMeasure13}", "${data.meals![0].strMeasure14}",
      "${data.meals![0].strMeasure15}",
    ];

    value.removeWhere((value) => value == "");
    valueMeasure.removeWhere((value) => value == "");

    int i = 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.brown.shade800,
            width: 5,
          ),
          borderRadius: BorderRadius.circular(15),
          color: Colors.brown.withOpacity(0.6),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: [
              const Text(
                "MAIN INGREDIENTS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontSize: 20.0,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, i) {
                  return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 5.0, color: Colors.brown),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return MealListPage(value: value[i], index: 2);
                          }));
                        },
                        splashColor: Colors.lightBlueAccent,
                        highlightColor: Colors.lightBlueAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Image.network(
                                "https://www.themealdb.com/images/ingredients/${value[i]}-Small.png",
                                width: 100.0,
                              ),
                              Text(
                                value[i].toTitleCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                valueMeasure[i].toTitleCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ));
                },
                itemCount: value.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
