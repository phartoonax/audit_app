// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:audit_app/screeens/detailproyek.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.userdata});
  final BackendlessUser userdata;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

bool loaded = false;

List<Map> listproyek =
    List<Map>.empty(growable: true); //ISI: PROYEK DAN SUPERVISOR
List<Map> listitemharian = List<Map>.empty(
    growable: true); //ISI: TIAP ITEM HARIAN, JENIS TRANSAKSI, PROYEK

class _MainScreenState extends State<MainScreen> {
  @override
  initState() {
    init();

    super.initState();
  }

  Future<void> init() async {
    listproyek.clear();
    listitemharian.clear();
    //GET ALL DATA
    //START CARI PROYEK
    DataQueryBuilder queryBuilder = DataQueryBuilder()
      ..related = ["penanggung_jawab"]
      ..relationsDepth = 1
      ..whereClause =
          "penanggung_jawab.objectId='${widget.userdata.getObjectId()}'";
    setState(() {
      Backendless.data.of('proyek').find(queryBuilder).then((value) {
        if (value != null) {
          value.forEach((element) {
            Map tolist = (element as Map);
            Backendless.data
                .of('item_rekap')
                .find(DataQueryBuilder()
                  ..properties = ["Sum(biaya) as Total"]
                  ..related = ["proyek_relasi"]
                  ..groupBy = ["proyek_relasi"]
                  ..relationsDepth = 1
                  ..whereClause =
                      "proyek_relasi.objectId='${element["objectId"]}'")
                .then((values) {
              if (values != null && values.isNotEmpty) {
                tolist.addAll(values.first as Map);
              }
              setState(() {
                listproyek.add(tolist);
              });
            });
          });
        }
      });
    });
    //END CARI PROYEK
    //START CARI ITEM HARIAN
    setState(() {
      Backendless.data
          .of('harian_rekap')
          .find(DataQueryBuilder()
            ..related = ["proyek_terkait", "item_terkait"]
            ..sortBy = ["tanggal DESC"]
            ..relationsDepth = 3)
          .then((values) {
        if (values != null) {
          values.forEach((element) {
            listitemharian.add(element as Map);
          });
        }
      });
    });

    //END CARI ITEM HARIAN
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: SizedBox(
      height: 1.sh,
      child: loaded
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 0.05.sh,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Halaman Utama: Rangkuman Proyek',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hai, ${widget.userdata.getProperty("username")}! Pilih salah satu proyek dibawah untuk menambah jurnal',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(
                    height: 0.7.sh,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: listproyek.length,
                        padding: EdgeInsets.all(4),
                        itemBuilder: (context, index) {
                          //cari item harian yang terkait dengan proyek index
                          List<Map> filteredharian = List.empty(growable: true);
                          if (listproyek[index].length > 9) {
                            filteredharian = listitemharian
                                .where((element) =>
                                    element['proyek_terkait']['objectId'] ==
                                    listproyek[index]['proyek_relasi']
                                        ['objectId'])
                                .toList();
                          }

                          return Card(
                              child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(listproyek[index]['nama_proyek'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: listproyek[index]['status_selesai']
                                          ? Text(
                                              'Selesai',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey),
                                            )
                                          : Text(
                                              'Dikerjakan',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color:
                                                      Colors.lightGreen[700]),
                                            ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      height: 23.5.h,
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4)),
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailProyek(
                                                          proyek:
                                                              listproyek[index],
                                                          userdata:
                                                              widget.userdata,
                                                        )));
                                          },
                                          child: Text("Detail Proyek",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromARGB(
                                                      255, 29, 63, 155)))),
                                    )
                                  ]),
                              childrenPadding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              children: [
                                Divider(
                                  endIndent: 5,
                                  indent: 5,
                                  color: Color.fromARGB(255, 99, 120, 136),
                                ),
                                (listproyek[index].length > 9)
                                    ? ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: filteredharian.length,
                                        padding: EdgeInsets.all(1),
                                        itemBuilder: (context, indexes) {
                                          var now = filteredharian[indexes]
                                              ['tanggal'];

                                          var formatter =
                                              new DateFormat('dd MMM yy');
                                          var formattedDate =
                                              formatter.format(now);

                                          //GET THIS AND TRANSFER TO DETAIL
                                          List<int> totalharian =
                                              List.empty(growable: true);
                                          (filteredharian[indexes]
                                                  ['item_terkait'])
                                              .forEach((element) {
                                            totalharian.add(int.parse(
                                                element['biaya'].toString()));
                                          });

                                          return ExpansionTile(
                                              title: Text(
                                                  formattedDate.toString(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                        "Pengeluaran Harian: "),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    margin: EdgeInsets.all(10),
                                                    child: Text(
                                                      CurrencyTextInputFormatter(
                                                              locale: 'id',
                                                              symbol: 'Rp. ',
                                                              decimalDigits: 0)
                                                          .format(totalharian
                                                              .sum
                                                              .toString()),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                Card(
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: 80.w,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              "Kegiatan",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 80.w,
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              "Jenis Kegiatan",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Container(
                                                          width: 65.w,
                                                          alignment:
                                                              Alignment.center,
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text("Waktu",
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            width: 150.w,
                                                            alignment: Alignment
                                                                .centerRight,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Text(
                                                                "Total Biaya",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      filteredharian[indexes]
                                                              ['item_terkait']
                                                          .length,
                                                  padding: EdgeInsets.all(0),
                                                  itemBuilder: (context, idx) {
                                                    // DETAIL WAKTU GET THIS ALSO
                                                    var nows =
                                                        filteredharian[indexes]
                                                                ['item_terkait']
                                                            [idx]['waktu'];

                                                    var formatters =
                                                        new DateFormat(
                                                            'h:mm a');
                                                    var formattedDates =
                                                        formatters.format(nows);
                                                    return Card(
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: 80.w,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                  filteredharian[indexes]['item_terkait']
                                                                              [
                                                                              idx]
                                                                          [
                                                                          'nama']
                                                                      [
                                                                      'nama_transaksi'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Container(
                                                              width: 80.w,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                  filteredharian[indexes]['item_terkait'][idx]['nama']
                                                                              [
                                                                              'jenis']
                                                                          [
                                                                          'nama_transaksi']
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            Container(
                                                              width: 65.w,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8),
                                                              child: Text(
                                                                formattedDates
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                width: 150.w,
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                child: Text(
                                                                    CurrencyTextInputFormatter(
                                                                            locale:
                                                                                'id',
                                                                            symbol:
                                                                                'Rp. ',
                                                                            decimalDigits:
                                                                                0)
                                                                        .format(filteredharian[indexes]['item_terkait'][idx]['biaya']
                                                                            .toString()),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                            ),
                                                          ]),
                                                    );
                                                  },
                                                ),
                                              ]);
                                        },
                                      )
                                    : Center(
                                        child: Text("Belum Ada Laporan Harian",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium),
                                      ),
                              ],
                            ),
                          ));
                        }),
                  )
                ],
              ),
            )
          : const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
    )));
  }
}
