import 'package:flutter/material.dart';

class U2UDetails extends StatelessWidget {
  const U2UDetails({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xfff7f6fb),
          iconTheme: IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Details',
            style: TextStyle(
                color: Colors.black
            ),
          )
      ),
      body: detailBody(args),
    );
  }

  Widget detailBody(args) {
    return  SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\u{20B9} ${args['total']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                ),
                Icon(
                  Icons.south_west_rounded,
                  color: Colors.green[300],
                  size: 45,
                ),
              ]
            ),
            SizedBox(height: 20,),
            Text(
              'Transactions with ${args['to']}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            SizedBox(height: 15,),
            transactionCard(),
            transactionCard(),
          ]
        )
      ),
    );
  }

  Widget transactionCard() {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                'Time',
                style: TextStyle(
                    fontSize: 10,
                ),
              ),
              Divider(
                  color: Colors.grey[300]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            child: Text('Y',
                               style: TextStyle(color: Colors.white)
                              ),
                              backgroundColor: Colors.redAccent
                          )
                      ),
                      Text('You'),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.arrow_forward_ios,
                            size: 10,
                          ),
                          Icon(Icons.arrow_forward_ios,
                            size: 10,
                          ),
                          Icon(Icons.arrow_forward_ios,
                            size: 10,
                          ),
                        ],
                      ),
                      Text('\u{20B9} amt')
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                            child: Text('H',
                                style: TextStyle(color: Colors.white)
                            ),
                            backgroundColor: Colors.redAccent
                        )
                      ),
                      Text('Him'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}
