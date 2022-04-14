from flask import *
from ssl import SSLContext, PROTOCOL_TLSv1_2 , CERT_REQUIRED
from cassandra.auth import PlainTextAuthProvider
from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.policies import WhiteListRoundRobinPolicy, DowngradingConsistencyRetryPolicy
from cassandra.query import SimpleStatement, tuple_factory
from cassandra import ConsistencyLevel
import hashlib
import min_transactions
from datetime import datetime

app = Flask(__name__)

ssl_context = SSLContext(PROTOCOL_TLSv1_2)
ssl_context.load_verify_locations('/home/shubham/Desktop/Desktop/Courses/Computer-System-Design/Project/udahriApp/udhaarKharcha/backend/sf-class2-root.crt')
ssl_context.verify_mode = CERT_REQUIRED
auth_provider = PlainTextAuthProvider(username='Admin-at-442245796012', password='Zo2yw3zb//WD1muANf3BPM9ZhzmO2jjDCczR+NsOx/4=')
cluster = Cluster(['cassandra.ap-south-1.amazonaws.com'], ssl_context=ssl_context, auth_provider=auth_provider, port=9142)
session = cluster.connect()

#cluster = Cluster()
#session = cluster.connect()

#session.set_keyspace('udhar_kharcha')

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
        return error('incorrect format')

    user_id = hashlib.md5(phone_no.encode()).hexdigest()
    print(user_id)

    query = SimpleStatement( \
                "INSERT INTO udhar_kharcha.user_profile (user_id, phone_no, username, upi_id) VALUES (%s, %s, %s, %s)", \
                consistency_level = ConsistencyLevel.LOCAL_QUORUM \
            )

    session.execute(query, (user_id, phone_no, username, upi_id))
    
    response = {'phone_no': phone_no, 'user_id': user_id}

    dictionary = {'success' : True , 'message' : "User created successfully" , 'data' : response}
    return jsonify(dictionary)

@app.route('/update_token', methods = ["POST"])
def updateFCMToken():
    input = request.get_json()
    try:
        phone_no = input["phone_no"]
        fcm_token = input["fcm_token"]
    except:
        error('incorrect format')

    user_id = hashlib.md5(phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement( \
                    "INSERT INTO udhar_kharcha.fcm_mapping (user_id, fcm_token) VALUES (%s, %s)", \
                    consistency_level = ConsistencyLevel.LOCAL_QUORUM \
                )

        session.execute(query, (user_id, fcm_token))
        return {"Success": "true"}
        
    except:
        return error('DB error')


'''
    input format = {
        "participants_paid" : {
            "9315943390" : 50,
            "9213751983" : 100,
            "9305480656" : 30
        },
        "participants_amount_on_bill" : {
            "9315943390" : 70,
            "9213751983" : 50,
            "9305480656" : 60
        },
        "event_name" : "cafe"
    }

'''

@app.route('/bill_split', methods = ["POST"])
def bill_split():
    input = request.get_json()
    try:
        participants_paid = input["participants_paid"]
        participants_amount_on_bill = input["participants_amount_on_bill"]
        event_name = input["event_name"]

    except:
        return error('incorrect format')
    if len(participants_paid) != len(participants_amount_on_bill) or len(participants_paid) > 14:
        return error('incorrect format')

    participants_paid_amount = 0
    for user in participants_paid:
        participants_paid_amount += participants_paid[user]
    bill_amount = 0
    for user in participants_amount_on_bill:
        bill_amount += participants_amount_on_bill[user]

    if participants_paid_amount != bill_amount:
        return error('inconsistant amounts')
    
    udhars_takers = []
    udhar_givers = []
    users_takers = []
    users_givers = []

    for user in participants_paid:
        try:
            if participants_paid[user] > participants_amount_on_bill[user]:
                users_givers.append(user)
                udhar_givers.append(participants_paid[user] - participants_amount_on_bill[user])
            elif participants_paid[user] < participants_amount_on_bill[user]:
                users_takers.append(user)
                udhars_takers.append(participants_amount_on_bill[user] - participants_paid[user])
        except:
            return error('incorrect format')
    min_transactions_for_cur_bill = min_transactions(udhars_takers, udhar_givers) #min_transactions class to compute min transactions
    min_transactions_for_cur_bill.get_transactions()
    udhar_givers_participants = min_transactions_for_cur_bill.final_create_udhar_giver_groups 
    udhar_takers_participants = min_transactions_for_cur_bill.final_create_udhar_taker_groups 

    pairwise_udhar = dict()
    for i in range(udhar_givers_participants):
        k = 0
        for j in range(udhar_givers_participants[i]):
            while udhar_givers[udhar_givers_participants[i][j]] > 0:
                if udhar_givers[udhar_givers_participants[i][j]] >= udhars_takers[udhar_takers_participants[i][k]]:
                    pairwise_udhar[(users_givers[udhar_givers_participants[i][j]], users_takers[udhar_takers_participants[i][k]])] = udhars_takers[udhar_takers_participants[i][k]]
                    udhar_givers[udhar_givers_participants[i][j]] -= udhars_takers[udhar_takers_participants[i][k]]
                    k += 1
                else:
                    pairwise_udhar[(users_givers[udhar_givers_participants[i][j]], users_takers[udhar_takers_participants[i][k]])] = udhar_givers[udhar_givers_participants[i][j]]
                    udhars_takers[udhar_takers_participants[i][k]] -= udhar_givers[udhar_givers_participants[i][j]]
    
    event_time = datetime.now()
    event_id = hashlib.md5(event_time.encode()).hexdigest()
    is_approved = [False] * len(pairwise_udhar)
    query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, pairwise_udhar, is_approved, event_participants, event_bill, event_time) VALUES (%s, %s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    session.execute(query, (event_name, event_id, pairwise_udhar, is_approved, participants_paid, participants_amount_on_bill, 100)) #change 100 to event time

    for user_pair in pairwise_udhar:
        #
        #    SEND NOTIFICATIONS TO PAIRS HERE
        #
        username_from = user_pair[0]
        username_to = username_to[1]
        try:
            #from A to B
            #store only records where A has to take from B
            query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET event_ids= event_ids + %s WHERE from_user_id=%s AND to_user_id=%s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            results = session.execute(query, ([event_id], username_from, username_to))
        except:
            try:
                query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, from_user_id, to_user_id, total_amount) VALUES (%s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                results = session.execute(query, ([event_id], username_from, username_to, 0))
            except:
                return error('DB error')
    
    success_response = {'success' : True , 'message' : 'bill_split added' , 'data' : {'display_msg' : 'bill_split added'} }
    return jsonify(success_response)
    


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
        r = session.execute(q, [from_user_id])
    except:
        return error('DB error')
    
    user_udhars = dict()
    for each_user in r.current_rows:
        user_udhars[each_user[1]] = each_user[3]
    
    dictionary = {'success' : True , 'message' : "All udhar for input user" , 'data' : user_udhars}
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

    print("here")
    
    participants_paid =  {str(username_from) : int(amount), str(username_to) : -int(amount)}

    event_time = datetime.now()
    event_id = hashlib.md5(event_time.strftime("%m/%d/%Y%H:%M:%S.%f").encode()).hexdigest()
    query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, event_participants, event_time) VALUES (%s, %s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    session.execute(query, (event_name, event_id, participants_paid, 10))

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
        try:
            query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, from_user_id, to_user_id, total_amount) VALUES (%s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            results = session.execute(query, ([event_id], username_from, username_to, amount))

            query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, from_user_id, to_user_id, total_amount) VALUES (%s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            results = session.execute(query, ([event_id], username_to, username_from, amount))
        except:
            return error('DB error')

    print("done")
    
    success_response = {'success' : True , 'message' : 'udhar added' , 'data' : {'display_msg' : 'udhar added'} }
    return jsonify(success_response)

@app.route('/personal_expense', methods=["POST"])
def personal_expense():
    input = request.get_json()
    try:
        username = input["username"]
        amount = input["amount"]
        event_name = input["event_name"]
    except:
        return error('incorrect format')

    try:
        event_time = datetime.now()
        event_id = hashlib.md5(event_time.strftime("%m/%d/%Y%H:%M:%S.%f").encode()).hexdigest()
        query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, event_time) VALUES (%s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        session.execute(query, (event_name, event_id, 10))

        query = SimpleStatement("INSERT INTO udhar_kharcha.personal_expense (event_id, username, amount) VALUES (%s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        session.execute(query, (event_id, username, amount))
        success_response = {'success' : True , 'message' : 'Personal Expense Added', 'data': ''}
        return jsonify(success_response)
    except:
        return error('DB error')

@app.route('/get_personal_expenses', methods=["POST"])
def get_personal_expenses():
    input = request.get_json()
    try:
        username = input["username"]
    except:
        return error('incorrect format')

    try:
        query = 'SELECT * FROM udhar_kharcha.personal_expense WHERE username = %s ALLOW FILTERING'
        response = session.execute(query, [username])
    except:
        return error('DB error')
    
    user_personal_expenses = list()
    query = "SELECT event_detail, event_time FROM udhar_kharcha.event_details WHERE event_id = %s ALLOW FILTERING"
    for expense in response.current_rows:
        try:
            response = session.execute(query, [expense.event_id])
            response = response.current_rows[0]
            user_personal_expenses.append([response.event_detail, response.event_time, expense.amount])
        except:
            print("here")
            continue
    
    dictionary = {'success' : True , 'message' : "All personal expenses for input user" , 'data' : user_personal_expenses}
    return jsonify(dictionary)

if __name__ == '__main__':
    app.run(debug = True, threaded = True)
