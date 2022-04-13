import 'package:flutter/material.dart';

class U2UDetails extends StatefulWidget {
  const U2UDetails({Key? key}) : super(key: key);

  @override
  State<U2UDetails> createState() => _U2UDetailsState();
}

class _U2UDetailsState extends State<U2UDetails> {
  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    
    bool isApproved = false;

    return Scaffold(
      backgroundColor: Color(0xfff7f6fb),
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xfff7f6fb),
          iconTheme: IconThemeData(color: Colors.purple),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
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
                transactionCard(),
                transactionCard(),
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
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
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
                              backgroundColor: Colors.green
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
                      Text(
                        '\u{20B9} amt',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                        ),
                      )
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {},
                      child: Text(
                          'Approve',
                        style: TextStyle(
                          color: Colors.green,
                        ),
                      )
                  ),
                  TextButton(onPressed: (){},
                    child: Text(
                      'Reject',
                      style: TextStyle(
                      color: Colors.red,
                    ),
                  )
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
