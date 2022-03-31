from flask import *
from ssl import SSLContext, PROTOCOL_TLSv1_2 , CERT_REQUIRED
from cassandra.auth import PlainTextAuthProvider
from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.policies import WhiteListRoundRobinPolicy, DowngradingConsistencyRetryPolicy
from cassandra.query import SimpleStatement, tuple_factory
from cassandra import ConsistencyLevel
import hashlib
from datetime import datetime

app = Flask(__name__)

ssl_context = SSLContext(PROTOCOL_TLSv1_2 )
ssl_context.load_verify_locations('./sf-class2-root.crt')
ssl_context.verify_mode = CERT_REQUIRED
auth_provider = PlainTextAuthProvider(username='Admin-at-442245796012', password='Zo2yw3zb//WD1muANf3BPM9ZhzmO2jjDCczR+NsOx/4=')
cluster = Cluster(['cassandra.ap-south-1.amazonaws.com'], ssl_context=ssl_context, auth_provider=auth_provider, port=9142)
session = cluster.connect()

def error(msg):
    dictionary = {'success' : False , 'message' : msg , 'data' : {} }
    return jsonify(dictionary)

@app.route('/')
def home():
    return 'Home'

@app.route('/signup', methods = ["POST"])
def signup():
    input = request.get_json()
    try:
        phone_no = input["phone_no"]
        username = input["username"]
        upi_id = input["upi_id"]
    except:
        pass
        # return error('incorrect format')

    user_id = hashlib.md5(phone_no.encode()).hexdigest()
    print(user_id)

    query = SimpleStatement( \
                "INSERT INTO user_profile (user_id, phone_no, username, upi_id) VALUES (%s, %s, %s, %s)" \
            )

    session.execute(query, (user_id, phone_no, username, upi_id))
    return {"Success": "true"}
'''
@app.route('/addUdhar', methods = ["POST"])
def addUdhar():
    input = request.get_json()
    try:
        participants_paid = input["participants_paid"]
        participants_amount_on_bill = input["bill"]
        event_name = input["event_name"]

    except:
        pass
        # return error('incorrect format')
    
    bill_amount = 0
    for user in participants_amount_on_bill:
        bill_amount += participants_amount_on_bill[user]
    
    event_time = now()
    event_id = hashlib.md5(event_time.encode()).hexdigest()
    query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, event_participants, event_time) VALUES (%s, %s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    session.execute(query, (event_name, event_id, participants_paid, event_time))
    #correct the users table event_participants map


    amount_paid_by_each = bill_amount/len(participants_paid)
    
'''


'''
    input format = {
        "username_from" : "123",
        "username_to" : "456",
        "amount" : 100,
        "event_name" : "cafe"
    }

'''

@app.route('/getUdhar', methods = ["POST"])
def getUdhar():
    input = request.get_json()
    try:
        from_user_id = input["username_from"] #assuming these are userids
    except:
        return error('incorrect format')
    
    try:
        q = 'SELECT * FROM udhar_kharcha.split_bills WHERE from_user_id = %s ALLOW FILTERING'
        r = session.execute(q, (from_user_id))
    except:
        return error('DB error')
    
    user_udhars = dict()
    for each_user in r.current_rows:
        user_udhars[each_user[1]] = each_user[3]
    
    dictionary = {'success' : True , 'message' : "All udhar for input user" , 'data' : {user_udhars} }
    return jsonify(dictionary)


@app.route('/addUdhar', methods = ["POST"])
def addUdhar():
    input = request.get_json()
    try:
        username_from = input["username_from"] #assuming these are userids
        username_to = input["username_to"]
        amount = input["amount"]
        event_name = input["event_name"]
        

    except:
        return error('incorrect format')
    
    participants_paid =  {username_from : amount, username_to : -amount}

    event_time = datetime.now()
    event_id = hashlib.md5(event_time.strftime("%m/%d/%Y%H:%M:%S.%f").encode()).hexdigest()
    query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, event_participants, event_time) VALUES (%s, %s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    session.execute(query, (event_name, event_id, participants_paid, event_time))

    try:
        q = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE from_user_id = %s AND to_user_id = %s'
        r = session.execute(q, (username_from, username_to))
        cur_amount = r.current_rows[0][0]
        total_amount = cur_amount + amount

        #from A to B
        query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET event_ids= event_ids + %s WHERE from_user_id=%s AND to_user_id=%s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, ([event_id], username_from, username_to))

        query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE from_user_id=%s AND to_user_id=%s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (total_amount, username_from, username_to))

        #from B to A
        query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET event_ids= event_ids + %s WHERE from_user_id=%s AND to_user_id=%s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, ([event_id], username_to, username_from))

        query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE from_user_id=%s AND to_user_id=%s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (total_amount, username_to, username_from))
    except:
        return error('DB error')

    try:
        query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, from_user_id, to_user_id, total_amount) VALUES (%s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, ([event_id], username_from, username_to, amount))
    except:
        return error('DB error')
    
    success_response = {'success' : True , 'message' : 'udhar added' , 'data' : {'display_msg' : 'udhar added'} }
    return jsonify(success_response)




'''@app.route('/personal_expense', methods=["POST"])
def personal_expense():
    input = request.get_json()
    try:
        

if __name__ == '__main__':
    app.run(debug = True, threaded = True)
'''

# cluster = Cluster()
# session = cluster.connect()

# session.execute(("CREATE KEYSPACE IF NOT EXISTS examples "
#                  "WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1' }"))
# session.execute("USE examples")
# session.execute("CREATE TABLE IF NOT EXISTS tbl_sample_kv (id uuid, value text, PRIMARY KEY (id))")
# prepared_insert = session.prepare("INSERT INTO tbl_sample_kv (id, value) VALUES (?, ?)")


# class SimpleQueryExecutor(threading.Thread):

#     def run(self):
#         global COUNTER

#         while True:
#             with COUNTER_LOCK:
#                 current = COUNTER
#                 COUNTER += 1

#             if current >= TOTAL_QUERIES:
#                 break

#             session.execute(prepared_insert, (uuid.uuid4(), str(current)))


# # Launch in parallel n async operations (n being the concurrency level)
# start = time.time()
# threads = []
# for i in range(CONCURRENCY_LEVEL):
#     t = SimpleQueryExecutor()
#     threads.append(t)
#     t.start()

# for thread in threads:
#     thread.join()
# end = time.time()

# print("Finished executing {} queries with a concurrency level of {} in {:.2f} seconds.".
#       format(TOTAL_QUERIES, CONCURRENCY_LEVEL, (end-start)))