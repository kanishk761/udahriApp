from turtle import ycor
from unittest import result
from urllib import response
from flask import *
from ssl import SSLContext, PROTOCOL_TLSv1_2 , CERT_REQUIRED
from cassandra.auth import PlainTextAuthProvider
from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.policies import WhiteListRoundRobinPolicy, DowngradingConsistencyRetryPolicy
from cassandra.query import SimpleStatement, tuple_factory
from cassandra import ConsistencyLevel
import hashlib
from min_transactions import min_transactions
from datetime import datetime
from notification import sendTokenNotification

app = Flask(__name__)

ssl_context = SSLContext(PROTOCOL_TLSv1_2)
ssl_context.load_verify_locations('/home/shubham/Desktop/Desktop/Courses/Computer-System-Design/Project/udahriApp/udhaarKharcha/backend/sf-class2-root.crt')
ssl_context.verify_mode = CERT_REQUIRED
auth_provider = PlainTextAuthProvider(username='Admin-at-442245796012', password='Zo2yw3zb//WD1muANf3BPM9ZhzmO2jjDCczR+NsOx/4=')
cluster = Cluster(['cassandra.ap-south-1.amazonaws.com'], ssl_context=ssl_context, auth_provider=auth_provider, port=9142)
session = cluster.connect()

def _response(_success, _message, _data):
    dictionary = {'success' : _success , 'message' : _message , 'data' : _data }
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
        return _response(False, 'incorrect format', '')

    user_id = hashlib.md5(phone_no.encode()).hexdigest()

    query = SimpleStatement("INSERT INTO udhar_kharcha.user_profile (user_id, phone_no, username, upi_id) VALUES (%s, %s, %s, %s)", consistency_level = ConsistencyLevel.LOCAL_QUORUM)

    session.execute(query, (user_id, phone_no, username, upi_id))
    
    response = {'phone_no': phone_no, 'user_id': user_id}

    return _response(True, "User created successfully", response)



@app.route('/update_token', methods = ["POST"])
def updateFCMToken():
    input = request.get_json()
    try:
        phone_no = input["phone_no"]
        fcm_token = input["fcm_token"]
    except:
        _response(False, 'incorrect format', '')

    user_id = hashlib.md5(phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement("INSERT INTO udhar_kharcha.fcm_mapping (user_id, fcm_token) VALUES (%s, %s)", consistency_level = ConsistencyLevel.LOCAL_QUORUM )

        session.execute(query, (user_id, fcm_token))
        return {"Success": "true"}
        
    except:
        return _response(False, 'DB error', '')



'''
    input format = {
        "user_id_from" : "9213751983",
        "user_id_to" : "9315943390"
    }

'''

@app.route('/get_pair_details', methods = ["POST"])
def get_pair_details():
    input = request.get_json()
    try:
        user_id_from = input["user_id_from"]
        user_id_to = input["user_id_to"]

    except:
        return _response(False, 'incorrect format', '')
    
    response_data = []


    user_id_to_user_id_from_concat = user_id_to + user_id_from
    pair_id_user_id_to_user_id_from = hashlib.md5(user_id_to_user_id_from_concat.encode()).hexdigest()

    q1 = 'SELECT event_ids FROM udhar_kharcha.split_bills WHERE pair_id = %s'
    r1 = session.execute(q1, [pair_id_user_id_to_user_id_from])

    events_id_take_list = []
    if len(r1.current_rows) > 0:
        events_id_take_list = r1.current_rows[0][0]



    user_id_from_user_id_to_concat = user_id_from + user_id_to
    pair_id_user_id_from_user_id_to = hashlib.md5(user_id_from_user_id_to_concat.encode()).hexdigest()

    q2 = 'SELECT event_ids FROM udhar_kharcha.split_bills WHERE pair_id = %s'
    r2 = session.execute(q2, [pair_id_user_id_from_user_id_to])

    events_id_give_list = []
    if len(r1.current_rows) > 0:
        events_id_give_list = r2.current_rows[0][0]
    

    i = 0
    j = 0
    while i < len(events_id_take_list) and j < len(events_id_give_list):
        q1 = 'SELECT event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
        r1 = session.execute(q1, [events_id_take_list[i]])

        q2 = 'SELECT event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
        r2 = session.execute(q2, [events_id_give_list[j]])

        timestamp1 = r1.current_rows[0][0]
        timestamp2 = r2.current_rows[0][0]

        if(timestamp1 > timestamp2):
            query = 'SELECT event_detail,pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
            result = session.execute(query, [events_id_take_list[i]])

            udhar_between_them = result.current_rows[0][1][pair_id_user_id_to_user_id_from]
            event_name = result.current_rows[0][0]
            event_data = (events_id_take_list[i], event_name, udhar_between_them, True) #final field True represents that amount has to be TAKEN

            response_data.append(event_data)
            i += 1
        else:
            query = 'SELECT event_detail,pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
            result = session.execute(query, [events_id_give_list[j]])

            udhar_between_them = result.current_rows[0][1][pair_id_user_id_from_user_id_to]
            event_name = result.current_rows[0][0]
            event_data = (events_id_give_list[j], event_name, udhar_between_them, False) #final field False represents that amount has to be GIVEN

            response_data.append(event_data)
            j += 1
        
    while i < len(events_id_take_list):
        query = 'SELECT event_detail,pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
        result = session.execute(query, [events_id_take_list[i]])

        udhar_between_them = result.current_rows[0][1][pair_id_user_id_to_user_id_from]
        event_name = result.current_rows[0][0]
        event_data = (events_id_take_list[i], event_name, udhar_between_them, True) #final field True represents that amount has to be TAKEN

        response_data.append(event_data)
        i += 1

    while j < len(events_id_give_list):
        query = 'SELECT event_detail,pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
        result = session.execute(query, [events_id_give_list[j]])

        udhar_between_them = result.current_rows[0][1][pair_id_user_id_from_user_id_to]
        event_name = result.current_rows[0][0]
        event_data = (events_id_give_list[j], event_name, udhar_between_them, False) #final field False represents that amount has to be GIVEN

        response_data.append(event_data)
        j += 1

    return _response(True, 'pair_details_returned', response_data)


'''
    ***Note: here user_phone_from is the device phone number
    input format = {
        "user_phone_from" : "+919213751983",
        "user_phone_to" : "+919315943390",
        "event_id" : "yoyo"
    }
'''
@app.route('/approve_udhar', methods = ["POST"])
def approve_udhar():
    input = request.get_json()
    try:
        user_phone_from = input["user_phone_from"]
        user_phone_to = input["user_phone_to"]
        event_id = input["event_id"]
    except:
        return _response(False, 'incorrect format', '')
    
    pair_concat = user_phone_to + user_phone_from
    pair_id = hashlib.md5(pair_concat.encode()).hexdigest()
    
    query = 'SELECT pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
    result = session.execute(query, [event_id])

    try:
        pairwise_udhar = result.current_rows[0][0]
    except:
        return _response(False, 'No such event', '')

    try:
        if pairwise_udhar[pair_id] < 0:
            query = 'UPDATE udhar_kharcha.event_details SET pairwise_udhar[%s] = %s WHERE event_id = %s'
            result = session.execute(query, [pair_id, -pairwise_udhar[pair_id], event_id])

            query = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE pair_id = %s'
            result = session.execute(query, [pair_id])

            current_amount = result.current_rows[0][0]

            query = 'UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE pair_id = %s'
            result = session.execute(query, [current_amount - pairwise_udhar[pair_id], pair_id])
        else:
            return _response(True, 'Already approved', '')
    except:
        return _response(False, 'No such pair in the event', '')
    
    return _response(True, 'Udhar approved!', '')

    
    

    




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
        return _response(False, 'incorrect format', '')
    if len(participants_paid) != len(participants_amount_on_bill) or len(participants_paid) > 14:
        return _response(False, 'incorrect format', '')

    participants_paid_amount = 0
    for user in participants_paid:
        participants_paid_amount += participants_paid[user]
    bill_amount = 0
    for user in participants_amount_on_bill:
        bill_amount += participants_amount_on_bill[user]

    if participants_paid_amount != bill_amount:
        return _response(False, 'inconsistent amounts', '')
    
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
            return _response(False, 'incorrect format', '')
    min_transactions_for_cur_bill = min_transactions(udhars_takers, udhar_givers) #min_transactions class to compute min transactions
    min_transactions_for_cur_bill.get_transactions()
    udhar_givers_participants = min_transactions_for_cur_bill.get_final_udhar_giver_groups() 
    udhar_takers_participants = min_transactions_for_cur_bill.get_final_udhar_taker_groups() 


    pairwise_udhar = dict()

    event_time = datetime.now()
    event_id = hashlib.md5(event_time.strftime("%m/%d/%Y%H:%M:%S.%f").encode()).hexdigest()

    for i in range(len(udhar_givers_participants)):
        k = 0
        for j in range(len(udhar_givers_participants[i])):
            while udhar_givers[udhar_givers_participants[i][j]] > 0:
                user_to = users_givers[udhar_givers_participants[i][j]]
                user_from = users_takers[udhar_takers_participants[i][k]]

                user_to_user_from_concat = user_to + user_from
                pair_id = hashlib.md5(user_to_user_from_concat.encode()).hexdigest()

                try:
                    #from A to B
                    #store only records where user_to has to take from user_from
                    query = SimpleStatement("UPDATE udhar_kharcha.split_bills SET event_ids= event_ids + %s WHERE pair_id = %s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    results = session.execute(query, ([event_id], pair_id))

                    # SEE CONVENTION ABOVE
                    from_user_id = hashlib.md5(users_givers[udhar_givers_participants[i][j]].encode()).hexdigest()
                    to_user_id = hashlib.md5(users_takers[udhar_takers_participants[i][k]].encode()).hexdigest()

                    query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, from_user_id, pair_id, to_user_id, total_amount) VALUES (%s, %s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    results = session.execute(query, ([event_id], from_user_id, pair_id, to_user_id, 0))

                    #When searching by primary key "ALLOW FILTERING" is NOT required
                    query = SimpleStatement("SELECT username, phone_no FROM udhar_kharcha.user_profile WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    result = session.execute(query, [from_user_id])
                    result = result.one()
                    from_user_name, from_user_phone_no = result.username, result.phone_no

                    query = SimpleStatement("SELECT fcm_token FROM udhar_kharcha.fcm_mapping WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    result = session.execute(query, [to_user_id])
                    result = result.one()
                    to_fcm_token = result.fcm_token

                    #CONFUSION
                    sendTokenNotification(to_fcm_token, from_user_name, from_user_phone_no, 30)

                except:
                    return _response(False, 'DB error', '')
                
                if udhar_givers[udhar_givers_participants[i][j]] >= udhars_takers[udhar_takers_participants[i][k]]:
                    pairwise_udhar[pair_id] = -udhars_takers[udhar_takers_participants[i][k]]
                    udhar_givers[udhar_givers_participants[i][j]] -= udhars_takers[udhar_takers_participants[i][k]]
                    k += 1
                else:
                    pairwise_udhar[pair_id] = -udhar_givers[udhar_givers_participants[i][j]]
                    udhars_takers[udhar_takers_participants[i][k]] -= udhar_givers[udhar_givers_participants[i][j]]
    
    try:
        query = SimpleStatement('INSERT INTO udhar_kharcha.event_details (event_detail, event_id, pairwise_udhar, event_payers, event_bill, event_time) VALUES (%s, %s, %s, %s, %s, %s);', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        session.execute(query, (event_name, event_id, pairwise_udhar, participants_paid, participants_amount_on_bill, event_time))
    except:
        return _response(False, 'DB error', '')

    return _response(True, 'bill_split added', {'display_msg' : 'bill_split added'})
    


'''
    input format = {
        "user_id" : "9315943390"
    }

'''

@app.route('/get_udhars', methods = ["POST"])
def getUdhars():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"] #assuming these are userids
    except:
        return _response(False, 'incorrect format', '')

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()
    
    try:
        #user_id recieving money
        q1 = 'SELECT from_user_id,total_amount FROM udhar_kharcha.split_bills WHERE to_user_id = %s ALLOW FILTERING'
        r1 = session.execute(q1, [user_id])
        #user_id paying money
        q2 = 'SELECT to_user_id,total_amount FROM udhar_kharcha.split_bills WHERE from_user_id = %s ALLOW FILTERING'
        r2 = session.execute(q2, [user_id])
    except:
        return _response(False, 'DB error', '')
    
    user_udhars = dict()

    for user in r1.current_rows:
        user_udhars[user[0]] = user[1]
    
    for user in r2.current_rows:
        if user[0] in user_udhars:
            user_udhars[user[0]] = user_udhars[user[0]] - user[1]
        else:
            user_udhars[user[0]] = -user[1]

    return _response(True, "All udhar for input user", user_udhars)



@app.route('/personal_expense', methods=["POST"])
def personal_expense():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
        amount = input["amount"]
        event_detail = input["event_detail"]
    except:
        return _response(False, 'incorrect format', '')

    event_time = datetime.now()
    event_id = hashlib.md5(event_time.strftime("%m/%d/%Y%H:%M:%S.%f").encode()).hexdigest()

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement("UPDATE udhar_kharcha.personal_expenses SET event_ids = event_ids + %s WHERE user_id = %s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, ([event_id], user_id))

        query = SimpleStatement("INSERT INTO udhar_kharcha.personal_expenses (user_id, event_ids) VALUES (%s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (user_id, [event_id]))

        query = SimpleStatement("INSERT INTO udhar_kharcha.event_details (event_id, event_bill, event_detail, event_payers, event_time) VALUES (%s, %s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (event_id, {user_phone_no: amount}, event_detail, {user_phone_no: amount}, event_time))

        return _response(True, 'Personal Expense Added', '')
    except:
        return _response(False, 'DB error', '')



@app.route('/get_personal_expenses', methods=["POST"])
def get_personal_expenses():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
    except:
        return _response(False, 'incorrect format', '')

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement("SELECT event_ids FROM udhar_kharcha.personal_expenses WHERE user_id = %s ALLOW FILTERING", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        response = session.execute(query, [user_id])
    except:
        return _response(False, 'DB error', '')
    
    user_personal_expenses = list()

    try:
        query = SimpleStatement("SELECT event_detail, event_time, event_bill FROM udhar_kharcha.event_details WHERE event_id = %s ALLOW FILTERING", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        for event_id in response.one().event_ids:
            try:
                event_response = session.execute(query, [event_id])
                event_response = event_response.one()
                user_personal_expenses.append([event_response.event_detail, event_response.event_time, dict(event_response.event_bill)[user_phone_no]])
            except:
                continue
    except:
        pass

    return _response(True, "All personal expenses for input user", user_personal_expenses)



@app.route('/event_details', methods = ["POST"])
def event_details():
    input = request.get_json()
    try:
        event_id = input["event_id"]
    except:
        return _response(False, 'incorrect format', '')

    try:
        query = SimpleStatement("SELECT event_bill, event_payers FROM udhar_kharcha.event_details WHERE event_id = %s ALLOW FILTERING", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        response = session.execute(query, [event_id])
        response = response.one()

        data = {'event_bill': dict(response.event_bill), 'event_payers': dict(response.event_payers)}

        dictionary = {'success' : True , 'message' : "Event details of input event" , 'data' : data}
        return dictionary
    except:
        return _response(False, 'DB error', '')



@app.route('/notification_details', methods=["POST"])
def notification_details():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
        notification_title = input["notification_title"]
        notification_body = input["notification_body"]
    except:
        return _response(False, 'incorrect format', '')

    notification_time = datetime.now()
    notification_id = hashlib.md5((user_phone_no+notification_time.strftime("%m/%d/%Y%H:%M:%S.%f")).encode()).hexdigest()

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement("UPDATE udhar_kharcha.user_notifications_mapping SET notification_ids = notification_ids + %s WHERE user_id = %s IF EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, ([notification_id], user_id))

        query = SimpleStatement("INSERT INTO udhar_kharcha.user_notifications_mapping (user_id, notification_ids) VALUES (%s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (user_id, [notification_id]))

        query = SimpleStatement("INSERT INTO udhar_kharcha.notification_details (notification_id, notification_title, notification_body, notification_time) VALUES (%s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        results = session.execute(query, (notification_id, notification_title, notification_body, notification_time))

        return _response(True, "Notification successfully added", '')
    except:
        return _response(False, 'DB error', '')



@app.route('/get_notification_details', methods=["POST"])
def get_notification_details():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
    except:
        return _response(False, 'incorrect format', '')

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

    try:
        query = SimpleStatement("SELECT notification_ids FROM udhar_kharcha.user_notifications_mapping WHERE user_id = %s ALLOW FILTERING", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        response = session.execute(query, [user_id])
    except:
        return _response(False, 'DB error', '')
    
    user_notifications = list()

    try:
        query = SimpleStatement("SELECT notification_body, notification_title, notification_time FROM udhar_kharcha.notification_details WHERE notification_id = %s ALLOW FILTERING", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        for notification_id in response.one().notification_ids:
            print(notification_id)
            try:
                notification_response = session.execute(query, [notification_id])
                notification_response = notification_response.one()
                user_notifications.append([notification_response.notification_title, notification_response.notification_body, notification_response.notification_time])
            except:
                continue
    except:
        pass

    return _response(True, "All personal expenses for input user", user_notifications)



if __name__ == '__main__':
    app.run(debug = True, threaded = True)
