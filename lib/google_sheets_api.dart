import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "steady-habitat-421319",
  "private_key_id": "b5c44ebfec2907b3a7ed6108a03f6a8f3fba4701",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCp4nQnkB6grU5+\nRd5WZ0xE0rF/TkhMG5vTmSwR4PqiZruudNjwjAybczvKlJgXjfQg1zIo/Mau4tHO\nWJeuN09ONYw4LSDGkwT/jXjKDTXCI6RJt93f4EaXedKAPcM+gJSy44UxhAVZQB0H\nK3rIMmYFEc9kzkbOy/YXM6qtl0jkhRwh5BSW73O3zQzoFXFWagr5VdYL2WEDDxfy\nYTAKVWLEaTK/xTtw+qQGAB3Hxf5tnQb+o9Fme1CREeLVGX2BE4E0CTfAHCCn+5qA\npD3JJT7NNJO4A7jRFYWjGvwbGfFf6RdoYrGsiCqMUTU5x/0s8NaRzWtYbYiN+iyZ\nHK1HqmXvAgMBAAECggEAT25o9fieQW1W5pafexHIaOOEh2wgRKmiBeE36FIjjhxv\nw4Wxy2MIIATUn4czx8uhKlvEAcMS2MGH7K2imhwVUhGacsey6/Xg3+YTZJGhoZjN\nn4Q/UwaHqxqUME7wg8BWBoB4DetXHuBp0ijju0hJSDSIHm+OTvGxqi6HrquuMt4/\nV17k8n/Xv1CbBfImZplUje8R3YglgSZkVT8mauv09sWpr3VMGFxuvnu+YliaQdz0\nNH2jvKMzPGIp3EZiTQFsS3mKoeEWNS/JU5AZitl6yjeY0t9h1XuCzZzI8dxBpldH\nmUoNcmECC5B1P3+p4doABChIAsQvhiijjK8/+wXnaQKBgQDtoEndo3zSJZ7k5FaE\nxK3OdtEeyZKrgp2r1RLOdWiBrWWP/9EigyHYGKjynP3WHZ+QHLk7oRQ870nZgQ5X\nrV00bHn/RnLXOqodFEbsVlPSpvinvl84m8OuIrzmO1AxC704VcYVn6mEoZZP8Qm8\nbC1vNW6HO1fDfpsrE2O/ndA3RwKBgQC3BT/M8mnguZBwXhjoE6LWciwG8UFKdVhX\nr9FOUe6uOwMluZ3onk74Bbs2upcyEhlPHsEkHpyO+cvCrgOqbuwyJYKldYyQSoBZ\nhpGZY4Vc3QI0eqqW5mWaDcCs5DXHJBi09SHH9AlfiexeKyxpN6oLiDIGx6N/+XxB\n1gj1Q4MAGQKBgAMtHU+lG8oDTrhohO+JYXldBTaQIzG/sTPWyUWRNDBnjO/7z2PS\ntOUaj0eO6aWvB675c1BkusyFtkr9+p8ZZiGJQagz3N0bn6J73ubR0JUEPlafqM4s\n5tSxCi1ZpZzCN2lFXDx1weJP9p5i7mpiV8kgwbV1CZtHWfOdcrvg9COJAoGAQZwq\nIQiOGDetpfq1pwzTBVlsmxiFtXGXt+eZeyA4FlGlcTK3fxqxaIx1bss5RIPkes6l\nopMuwLqf5yyGt+SH2/pCeZpIR7nNhUqOi5R3zLCWB8YpvWre5Xkkp1YwSTGRgd2W\nvJ2pdox1JdUIWLfRx8yNUozi+g+wEdHu6C3JmpECgYBo3tnP/ggQItAcxworvpgZ\nC5b9PypLAMo/ONN24oBsZe+KLTmrM/8YDCq/c6sJatPtbor7JGTwIyjx39sBGybc\nKhCdRq+4vdPYy83llLoygKCUTtsIBwaa+WyAXfCDsYYf8/md+txFx/ikq755X9Lc\nsUVU0oehsn/aglCvYWPltQ==\n-----END PRIVATE KEY-----\n",
  "client_email": "expense-tracker@steady-habitat-421319.iam.gserviceaccount.com",
  "client_id": "101369589857032850025",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expense-tracker%40steady-habitat-421319.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  }
  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1Zr_MVT--aKoPea05nGytvJTsFe0khcS1koMAtgzRf6M';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
        .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
      await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
      await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
      await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) {
      print("Workshhet is null");
      return;
    }
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
