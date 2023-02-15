import 'dart:developer';

import 'package:audit_app/screeens/mainscreen.dart';
import 'package:audit_app/screeens/newchangeitem.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class DetailProyek extends StatefulWidget {
  const DetailProyek({super.key, required this.proyek, required this.userdata});

  final Map proyek;
  final BackendlessUser userdata;

  @override
  State<DetailProyek> createState() => _DetailProyekState();
}

List<Map> daftarharian =
    List<Map>.empty(growable: true); //ISI: PROYEK DAN SUPERVISOR
Map itemproyek = {};
bool isloaded = false;

class _DetailProyekState extends State<DetailProyek> {
  @override
  initState() {
    init();

    super.initState();
  }

  Future<void> init() async {
    daftarharian.clear();

    itemproyek = widget.proyek;
    Backendless.data
        .of('proyek')
        .findById(itemproyek['objectId'], relationsDepth: 1, relations: [
      "penanggung_jawab"
    ]).then((value) => setState(() {
              itemproyek.clear();
              itemproyek = value!;
            }));

    if (itemproyek.length > 9) {
      Backendless.data
          .of('harian_rekap')
          .find(DataQueryBuilder()
            ..whereClause =
                "proyek_terkait.objectId='${itemproyek["proyek_relasi"]["objectId"]}'"
            ..related = ["item_terkait"]
            ..relationsDepth = 3
            ..sortBy = ["tanggal DESC"])
          .then((value) {
        if (value != null) {
          value.forEach((element) {
            setState(() {
              daftarharian.add(element as Map);
              isloaded = true;
            });
          });
        }
      });
    } else {
      setState(() {
        isloaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proyek: ${itemproyek['nama_proyek']}'),
        leading: CloseButton(
          onPressed: () {
            itemproyek.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        userdata: widget.userdata,
                      )),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00468C),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          bool isnewday;
          if (daftarharian.isNotEmpty) {
            if (DateTime.now().day == daftarharian.first['tanggal'].day) {
              isnewday = false;
            } else {
              isnewday = true;
            }
          } else {
            isnewday = true;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TambahEditPage(
                      proyek: itemproyek,
                      userdata: widget.userdata,
                      isnewday: isnewday,
                      idharian:
                          isnewday ? null : daftarharian.first['objectId'],
                    )),
          ).then((value) => init());
        },
      ),
      body: SingleChildScrollView(
          child: SizedBox(
        height: 0.85.sh,
        child: Column(
          children: isloaded
              ? [
                  Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                "Pengeluaran Proyek:\n${CurrencyTextInputFormatter(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(itemproyek['Total'].toString())}",
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 17)),
                          ),
                          SizedBox(width: 0.25.sw),
                          Expanded(
                            child: Text(
                                itemproyek['status_selesai']
                                    ? "Status: \n Selesai"
                                    : "Status: \n Dikerjakan",
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 17)),
                          )
                        ],
                      )),
                  (itemproyek.length > 9)
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: daftarharian.length,
                          itemBuilder: (context, index) {
                            var now = daftarharian[index]['tanggal'];

                            var formatter = DateFormat('dd MMM yy');
                            var formattedDate = formatter.format(now);

                            List<int> totalharian = List.empty(growable: true);
                            (daftarharian[index]['item_terkait'])
                                .forEach((element) {
                              totalharian
                                  .add(int.parse(element['biaya'].toString()));
                            });
                            return ExpansionTile(
                              title: Text(formattedDate.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    child: const Text("Pengeluaran Harian: "),
                                  ),
                                  const Spacer(),
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Text(
                                      CurrencyTextInputFormatter(
                                              locale: 'id',
                                              symbol: 'Rp. ',
                                              decimalDigits: 0)
                                          .format(totalharian.sum.toString()),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: daftarharian[index]['item_terkait']
                                      .length,
                                  itemBuilder: (context, index2) {
                                    var nows = daftarharian[index]
                                        ['item_terkait'][index2]['waktu'];

                                    var formatters = new DateFormat('h:mm a');
                                    var formattedDates =
                                        formatters.format(nows);
                                    return ListTile(
                                        title: RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: daftarharian[index]
                                                          ['item_terkait']
                                                      [index2]['nama']['jenis']
                                                  ['nama_transaksi'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 253, 62, 48))),
                                          const TextSpan(
                                              text: " | ",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 46, 46, 46))),
                                          TextSpan(
                                              text: daftarharian[index]
                                                      ['item_terkait'][index2]
                                                  ['nama']['nama_transaksi'],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0))),
                                        ])),
                                        subtitle: Text(
                                            "${daftarharian[index]['item_terkait'][index2]['volume']}${daftarharian[index]['item_terkait'][index2]['nama']['satuan']} * ${daftarharian[index]['item_terkait'][index2]['biayasatuan']}"),
                                        trailing: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 9.0),
                                          child: Column(
                                            children: [
                                              Text(formattedDates.toString(),
                                                  textAlign: TextAlign.end),
                                              Text(CurrencyTextInputFormatter(
                                                      locale: 'id',
                                                      symbol: 'Rp. ',
                                                      decimalDigits: 0)
                                                  .format(daftarharian[index]
                                                              ['item_terkait']
                                                          [index2]['biaya']
                                                      .toString())),
                                            ],
                                          ),
                                        ));
                                  },
                                )
                              ],
                            );
                          },
                        )
                      : Center(
                          child: Text("Belum Ada Laporan Harian",
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        )
                ]
              : [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Loading Options...'),
                  ),
                ],
        ),
      )),
    );
  }
}
