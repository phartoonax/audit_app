import 'package:audit_app/screeens/detailproyek.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class TambahEditPage extends StatefulWidget {
  const TambahEditPage(
      {super.key,
      required this.proyek,
      required this.userdata,
      this.idedit,
      required this.isnewday,
      this.idharian});
  final bool isnewday;
  final String? idharian;
  final Map proyek;
  final BackendlessUser userdata;
  final String? idedit;
  @override
  State<TambahEditPage> createState() => _TambahEditPageState();
}

List<Map> daftarharian =
    List<Map>.empty(growable: true); //ISI: PROYEK DAN SUPERVISOR
Map itemproyek = {};

class _TambahEditPageState extends State<TambahEditPage> {
  bool isloaded = true;
  bool isjenisselected = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController namajenisController = TextEditingController();
  String? dropdownjenis;
  List<Map> listdropdownjenis = List.empty(growable: true);

  final TextEditingController namatransaksibaruController =
      TextEditingController();
  final TextEditingController satuantransaksibaruController =
      TextEditingController();
  String? dropdownnama;
  List<Map> listdropdownnama = List.empty(growable: true);
  List<Map> filterednama = List.empty(growable: true);

  final TextEditingController volumeController = TextEditingController();
  int? volcalc;
  String satuan = 'satuan';
  TimeOfDay waktu = TimeOfDay.now();
  DateTime nows = DateTime.now();

  final TextEditingController satuanController = TextEditingController();
  int? satcalc;
  String? onerror;

  String idproyek = "";
  @override
  initState() {
    itemproyek = widget.proyek;
    idproyek = (itemproyek.length > 9)
        ? itemproyek['proyek_relasi']['objectId']
        : itemproyek['objectId'];
    init();

    super.initState();
  }

  Future<void> init() async {
    //CARI DATA JENIS TRANSAKSI
    Backendless.data.of('jenis_transaksi').find().then((value) {
      if (value != null) {
        for (var element in value) {
          setState(() {
            listdropdownjenis.add(element!);
          });
        }
      }
    });
    Backendless.data
        .of('item_transaksi')
        .find(DataQueryBuilder()
          ..related = ['jenis']
          ..relationsDepth = 1)
        .then((value) {
      if (value != null) {
        for (var element in value) {
          listdropdownnama.add(element!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.idedit != null) {}
    final hours = waktu.hour.toString().padLeft(2, '0');
    final minutes = waktu.minute.toString().padLeft(2, '0');
    return Scaffold(
        appBar: AppBar(
          title: Text('Proyek: ${itemproyek['nama_proyek']}'),
          leading: CloseButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailProyek(
                        userdata: widget.userdata,
                        proyek: itemproyek,
                      )),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  setState(() async {
                    TimeOfDay? newtime = await showTimePicker(
                        context: context, initialTime: waktu);
                    if (newtime == null) {
                      return;
                    } else {
                      setState(() {
                        waktu = newtime;
                      });
                    }
                  });
                },
                child: Text("Wkt Kegiatan: $hours:$minutes"))
          ],
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: 0.85.sh,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: isloaded
                        ? [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Jenis Transaksi :",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    width: 170.w,
                                    height: 41.h,
                                    child: DropdownButtonFormField(
                                      value: dropdownjenis,
                                      validator: (value) => value == null
                                          ? 'field tidak boleh kosong'
                                          : null,
                                      hint: const Text("Pilih Jenis Transaksi"),
                                      items: listdropdownjenis
                                          .map((e) => DropdownMenuItem(
                                              value: e['objectId'],
                                              child: Text(e['nama_transaksi'])))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          isjenisselected = true;
                                          dropdownjenis = value as String?;
                                          dropdownnama = null;
                                          filterednama = listdropdownnama
                                              .where((element) =>
                                                  element['jenis']
                                                      ['objectId'] ==
                                                  dropdownjenis)
                                              .toList();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      width: 100.w,
                                      height: 30.h,
                                      child: TextButton(
                                        onPressed: () {
                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title: const Text(
                                                  'Tambah Jenis Transaksi'),
                                              content: SizedBox(
                                                height: 0.3.sh,
                                                child: Column(
                                                  children: [
                                                    const Text(
                                                        "Isi data dibawah ini untuk menambahkan jenis transaksi baru. Lalu, silahkan tekan tombol 'OK' untuk mengkonfirmasi"),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Text("Nama : ",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16)),
                                                          Container(
                                                            width: 160.w,
                                                            height: 30.h,
                                                            child: TextField(
                                                              textCapitalization:
                                                                  TextCapitalization
                                                                      .words,
                                                              style: TextStyle(
                                                                  fontSize: 17),
                                                              decoration:
                                                                  const InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(4),
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              controller:
                                                                  namajenisController,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'Cancel'),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Backendless.data
                                                        .of('jenis_transaksi')
                                                        .save({
                                                      "nama_transaksi":
                                                          namajenisController
                                                              .text
                                                    }).then(
                                                      (value) {
                                                        if (value != null) {
                                                          listdropdownjenis
                                                              .add(value);
                                                          final sbarnoticeabsen =
                                                              SnackBar(
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            duration: Duration(
                                                                seconds: 4),
                                                            content: Text(value[
                                                                    'nama_transaksi'] +
                                                                " berhasil ditambahkan!"),
                                                            action:
                                                                SnackBarAction(
                                                              label: 'OK',
                                                              onPressed: () =>
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .hideCurrentSnackBar(),
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  sbarnoticeabsen);
                                                          Navigator.pop(
                                                              context, 'OK');
                                                        }
                                                      },
                                                    );
                                                    namajenisController.clear();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3)),
                                        child: const Text("Tambah Jenis"),
                                      )),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Nama Transaksi :",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  Container(
                                    width: 170.w,
                                    height: 41.h,
                                    child: DropdownButtonFormField(
                                      validator: (value) => value == null
                                          ? 'field tidak boleh kosong'
                                          : null,
                                      value: dropdownnama,
                                      hint: const Text("Nama Transaksi"),
                                      items: filterednama
                                          .map((e) => DropdownMenuItem(
                                              value: e['objectId'],
                                              child: Text(e['nama_transaksi'])))
                                          .toList(),
                                      onChanged: isjenisselected
                                          ? (value) {
                                              setState(() {
                                                var temp = (filterednama
                                                    .firstWhere((element) =>
                                                        element['objectId'] ==
                                                        value)['satuan']);

                                                satuan = temp;
                                                dropdownnama = value as String?;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      width: 140.w,
                                      height: 30.h,
                                      child: TextButton(
                                        onPressed: () {
                                          if (isjenisselected) {
                                            showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title: const Text(
                                                    'Tambah Transaksi'),
                                                content: SizedBox(
                                                  height: 0.3.sh,
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                          "Isi data dibawah ini untuk menambahkan transaksi dan satuan baru. Lalu, silahkan tekan tombol 'OK' untuk mengkonfirmasi"),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5),
                                                        child: Text(
                                                            // ignore: prefer_interpolation_to_compose_strings
                                                            "Jenis Transaksi : " +
                                                                listdropdownjenis.firstWhere((element) =>
                                                                        element[
                                                                            'objectId'] ==
                                                                        dropdownjenis)[
                                                                    'nama_transaksi'],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                "Nama Trans: ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16)),
                                                            Container(
                                                              width: 120.w,
                                                              height: 30.h,
                                                              child: TextField(
                                                                textCapitalization:
                                                                    TextCapitalization
                                                                        .words,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                                controller:
                                                                    namatransaksibaruController,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 16.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                "Satuan Trans: ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16)),
                                                            Container(
                                                              width: 120.w,
                                                              height: 30.h,
                                                              child: TextField(
                                                                textCapitalization:
                                                                    TextCapitalization
                                                                        .words,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17),
                                                                decoration:
                                                                    const InputDecoration(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  border:
                                                                      OutlineInputBorder(),
                                                                ),
                                                                controller:
                                                                    satuanController,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, 'Cancel'),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Backendless.data
                                                          .of('item_transaksi')
                                                          .save({
                                                        "nama_transaksi":
                                                            namatransaksibaruController
                                                                .text,
                                                        "satuan":
                                                            satuanController
                                                                .text
                                                      }).then(
                                                        (value) {
                                                          if (value != null) {
                                                            Backendless.data
                                                                .of(
                                                                    'item_transaksi')
                                                                .setRelation(
                                                                    value[
                                                                        'objectId'],
                                                                    "jenis",
                                                                    childrenObjectIds: [
                                                                  dropdownjenis
                                                                      .toString()
                                                                ]).then(
                                                                    (values) {
                                                              setState(() {
                                                                listdropdownnama
                                                                    .add(value);
                                                                filterednama
                                                                    .add(value);
                                                              });
                                                            });
                                                            final sbarnoticeabsen =
                                                                SnackBar(
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          4),
                                                              content: Text(value[
                                                                      "nama_transaksi"] +
                                                                  " berhasil ditambahkan!"),
                                                              action:
                                                                  SnackBarAction(
                                                                label: 'OK',
                                                                onPressed: () =>
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .hideCurrentSnackBar(),
                                                              ),
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    sbarnoticeabsen);
                                                            Navigator.pop(
                                                                context, 'OK');
                                                          }
                                                        },
                                                      );
                                                      namatransaksibaruController
                                                          .clear();
                                                      satuanController.clear();
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            final sbarnoticeabsen = SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              duration: Duration(seconds: 4),
                                              content: Text(
                                                  "Pilih jenis terlebih dahulu!"),
                                              action: SnackBarAction(
                                                label: 'OK',
                                                onPressed: () =>
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar(),
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(sbarnoticeabsen);
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3)),
                                        child:
                                            const Text("Tambah transaksi baru"),
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Volume :",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  const Spacer(
                                    flex: 2,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    width: 60.w,
                                    height: 30.h,
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      controller: volumeController,
                                      validator: (value) => value == null
                                          ? 'field tidak boleh kosong'
                                          : null,
                                      onChanged: (val) {
                                        setState(() {
                                          volcalc = int.parse(val);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(4),
                                        border: OutlineInputBorder(),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  Text(satuan,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("Satuan :",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                  const Spacer(
                                    flex: 2,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    width: 100.w,
                                    height: 30.h,
                                    child: TextFormField(
                                      validator: (value) => value == null
                                          ? 'field tidak boleh kosong'
                                          : null,
                                      textAlign: TextAlign.end,
                                      controller: satuanController,
                                      onChanged: (val) {
                                        setState(() {
                                          satcalc = int.parse(val);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(4),
                                        border: OutlineInputBorder(),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  Text(' / $satuan',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  Text(
                                      (satuanController.text != "" &&
                                              volumeController.text != "")
                                          ? CurrencyTextInputFormatter(
                                                  locale: 'id',
                                                  symbol: 'Rp. ',
                                                  decimalDigits: 0)
                                              .format((volcalc! * satcalc!)
                                                  .toString())
                                          : "-",
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Backendless.data.of('item_rekap').save({
                                    "volume": volcalc,
                                    "biayasatuan": satcalc,
                                    "waktu": DateTime(
                                      nows.year,
                                      nows.month,
                                      nows.day,
                                      int.parse(hours),
                                      int.parse(minutes),
                                    ),
                                  }).then(
                                    (value) {
                                      if (value != null) {
                                        Backendless.data
                                            .of('item_rekap')
                                            .setRelation(
                                                value['objectId'], "nama",
                                                childrenObjectIds: [
                                              dropdownnama.toString()
                                            ]).then((values) {});
                                        //ADD RELATIONS HARIAN
                                        if (widget.isnewday) {
                                          Backendless.data
                                              .of('harian_rekap')
                                              .save({
                                            "tanggal": DateTime(
                                              nows.year,
                                              nows.month,
                                              nows.day,
                                            ),
                                          }).then(
                                            (valueese) {
                                              if (valueese != null) {
                                                Backendless.data
                                                    .of('harian_rekap')
                                                    .addRelation(
                                                        valueese['objectId'],
                                                        "item_terkait",
                                                        childrenObjectIds: [
                                                      value['objectId']
                                                    ]);
                                                Backendless.data
                                                    .of('harian_rekap')
                                                    .addRelation(
                                                        valueese['objectId'],
                                                        "proyek_terkait",
                                                        childrenObjectIds: [
                                                      idproyek
                                                    ]);
                                              }
                                            },
                                          );
                                        } else {
                                          Backendless.data
                                              .of('harian_rekap')
                                              .addRelation(widget.idharian!,
                                                  "item_terkait",
                                                  childrenObjectIds: [
                                                value['objectId']
                                              ]);
                                        }

                                        Backendless.data
                                            .of('item_rekap')
                                            .setRelation(value['objectId'],
                                                "proyek_relasi",
                                                childrenObjectIds: [
                                              idproyek
                                            ]).then((values) {});
                                        final sbarnoticeabsen = SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 4),
                                          content:
                                              Text(" berhasil ditambahkan!"),
                                          action: SnackBarAction(
                                            label: 'OK',
                                            onPressed: () =>
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar(),
                                          ),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(sbarnoticeabsen);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailProyek(
                                                      proyek: itemproyek,
                                                      userdata: widget.userdata,
                                                    )));
                                      }
                                    },
                                  );
                                } else {
                                  final sbarnoticeabsen = SnackBar(
                                    duration: const Duration(seconds: 4),
                                    content: const Text(
                                        "Isi semua field yang tersedia!"),
                                    action: SnackBarAction(
                                      label: 'OK',
                                      onPressed: () =>
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar(),
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(sbarnoticeabsen);
                                }
                              },
                              child: const Text("Tambahkan Jurnal"),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      const Color.fromARGB(255, 150, 211, 252)),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(15)),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(fontSize: 16))),
                            ),
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
                  )),
            ),
          ),
        ));
  }
}
