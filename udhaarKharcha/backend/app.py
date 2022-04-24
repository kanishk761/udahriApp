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
from datetime import datetime, date, timedelta
from dateutil.relativedelta import relativedelta, MO
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

@app.route('/delete')
def delete():
    query = "SELECT event_id FROM udhar_kharcha.event_details"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.event_details WHERE event_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    # query = "SELECT user_id FROM udhar_kharcha.fcm_mapping"
    # result = session.execute(query)
    # for id in result.current_rows:
    #     query = SimpleStatement("DELETE FROM udhar_kharcha.fcm_mapping WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    #     result = session.execute(query, [id[0]])

    query = "SELECT notification_id FROM udhar_kharcha.notification_details"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.notification_details WHERE notification_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    query = "SELECT user_id FROM udhar_kharcha.personal_expenses"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.personal_expenses WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    query = "SELECT pair_id FROM udhar_kharcha.split_bills"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.split_bills WHERE pair_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    query = "SELECT transaction_id FROM udhar_kharcha.transaction_history"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.transaction_history WHERE transaction_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    query = "SELECT user_id FROM udhar_kharcha.user_notifications_mapping"
    result = session.execute(query)
    for id in result.current_rows:
        query = SimpleStatement("DELETE FROM udhar_kharcha.user_notifications_mapping WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [id[0]])

    # query = "SELECT user_id FROM udhar_kharcha.user_profile"
    # result = session.execute(query)
    # for id in result.current_rows:
    #     query = SimpleStatement("DELETE FROM udhar_kharcha.user_profile WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
    #     result = session.execute(query, [id[0]])
    return 'uerj'


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

    to ka device, from pe tap

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
    if len(r1.current_rows) > 0 and r1.current_rows[0][0] is not None:
        events_id_take_list = r1.current_rows[0][0]



    user_id_from_user_id_to_concat = user_id_from + user_id_to
    pair_id_user_id_from_user_id_to = hashlib.md5(user_id_from_user_id_to_concat.encode()).hexdigest()

    q2 = 'SELECT event_ids FROM udhar_kharcha.split_bills WHERE pair_id = %s'
    r2 = session.execute(q2, [pair_id_user_id_from_user_id_to])

    events_id_give_list = []
    if len(r2.current_rows) > 0 and r2.current_rows[0][0] is not None:
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
            event_data = (events_id_take_list[i], event_name, udhar_between_them, timestamp1, True) #final field True represents that amount has to be TAKEN

            response_data.append(event_data)
            i += 1
        else:
            query = 'SELECT event_detail,pairwise_udhar FROM udhar_kharcha.event_details WHERE event_id = %s'
            result = session.execute(query, [events_id_give_list[j]])

            udhar_between_them = result.current_rows[0][1][pair_id_user_id_from_user_id_to]
            event_name = result.current_rows[0][0]
            event_data = (events_id_give_list[j], event_name, udhar_between_them, timestamp2, False) #final field False represents that amount has to be GIVEN

            response_data.append(event_data)
            j += 1
        
    while i < len(events_id_take_list):
        query = 'SELECT event_detail,pairwise_udhar,event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
        result = session.execute(query, [events_id_take_list[i]])

        udhar_between_them = result.current_rows[0][1][pair_id_user_id_to_user_id_from]
        event_name = result.current_rows[0][0]
        event_data = (events_id_take_list[i], event_name, udhar_between_them, result.current_rows[0][2], True) #final field True represents that amount has to be TAKEN

        response_data.append(event_data)
        i += 1

    while j < len(events_id_give_list):
        query = 'SELECT event_detail,pairwise_udhar,event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
        result = session.execute(query, [events_id_give_list[j]])

        udhar_between_them = result.current_rows[0][1][pair_id_user_id_from_user_id_to]
        event_name = result.current_rows[0][0]
        event_data = (events_id_give_list[j], event_name, udhar_between_them, result.current_rows[0][2], False) #final field False represents that amount has to be GIVEN

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

    # reverse_pair_concat = user_phone_from + user_phone_to
    # reverse_pair_id = hashlib.md5(reverse_pair_concat.encode()).hexdigest()

    
    query = 'SELECT pairwise_udhar, event_detail, event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
    result = session.execute(query, [event_id])

    try:
        result = result.one()
        pairwise_udhar = result.pairwise_udhar
        event_detail = result.event_detail
        event_time = result.event_time
    except:
        return _response(False, 'No such event', '')


    try:
        if pairwise_udhar[pair_id] < 0:
            query = SimpleStatement('UPDATE udhar_kharcha.event_details SET pairwise_udhar[%s] = %s WHERE event_id = %s', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            result = session.execute(query, (pair_id, -pairwise_udhar[pair_id], event_id))

            query = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE pair_id = %s'
            result = session.execute(query, [pair_id])

            current_amount = result.current_rows[0][0]

            # query = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE pair_id = %s'
            # result = session.execute(query, [reverse_pair_id])

            # reverse_current_amount = result.current_rows[0][0]


            query = SimpleStatement('UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE pair_id = %s', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            result = session.execute(query, [current_amount - pairwise_udhar[pair_id], pair_id])

            # query = SimpleStatement('UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE pair_id = %s', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
            # result = session.execute(query, [reverse_current_amount - pairwise_udhar[pair_id], reverse_pair_id])
        else:
            return _response(True, 'Already approved', '')
    except Exception as e:
        return _response(False, 'No such pair in the event', '')

    from_user_id = hashlib.md5(user_phone_from.encode()).hexdigest()
    to_user_id = hashlib.md5(user_phone_to.encode()).hexdigest()

    try:
        query = 'SELECT phone_no, username FROM udhar_kharcha.user_profile WHERE user_id = %s'
        result = session.execute(query, [from_user_id])
        result = result.one()
        from_user_name = result.username
        from_user_phone_no = result.phone_no

        query = 'SELECT fcm_token FROM udhar_kharcha.fcm_mapping WHERE user_id = %s'
        result = session.execute(query, [to_user_id])
        result = result.one()
        to_fcm_token = result.fcm_token
    except:
        return _response(False, 'DB error', '')

    event_time = event_time.strftime("%b %d, %Y")

    title = 'Debt Approved'
    body = '{0} ({1}) has approved your request to pay you \u20B9 {2} for {3} on {4}'.format(from_user_name, from_user_phone_no, str(-pairwise_udhar[pair_id]), event_detail, event_time)
    image = 'https://www.clipartmax.com/png/middle/157-1575710_open-approve-icon.png'

    try:
        sendTokenNotification(to_fcm_token, title, body, image)
    except:
        pass
    notification_details(user_phone_to, title, body)
    
    return _response(True, 'Udhar approved!', '')



@app.route('/reject_udhar', methods = ["POST"])
def reject_udhar():
    input = request.get_json()
    try:
        user_phone_from = input["user_phone_from"]
        user_phone_to = input["user_phone_to"]
        event_id = input["event_id"]
    except:
        return _response(False, 'incorrect format', '')

    pair_concat = user_phone_to + user_phone_from
    pair_id = hashlib.md5(pair_concat.encode()).hexdigest()

    
    query = 'SELECT pairwise_udhar, event_detail, event_time FROM udhar_kharcha.event_details WHERE event_id = %s'
    result = session.execute(query, [event_id])

    try:
        result = result.one()
        pairwise_udhar = result.pairwise_udhar
        event_detail = result.event_detail
        event_time = result.event_time
    except:
        return _response(False, 'No such event', '')

    from_user_id = hashlib.md5(user_phone_from.encode()).hexdigest()
    to_user_id = hashlib.md5(user_phone_to.encode()).hexdigest()

    try:
        query = 'SELECT phone_no, username FROM udhar_kharcha.user_profile WHERE user_id = %s'
        result = session.execute(query, [from_user_id])
        result = result.one()
        from_user_name = result.username
        from_user_phone_no = result.phone_no

        query = 'SELECT fcm_token FROM udhar_kharcha.fcm_mapping WHERE user_id = %s'
        result = session.execute(query, [to_user_id])
        result = result.one()
        to_fcm_token = result.fcm_token
    except:
        return _response(False, 'DB error', '')

    event_time = event_time.strftime("%b %d, %Y")

    title = 'Debt Rejected'
    body = '{0} ({1}) has rejected your request to pay you \u20B9 {2} for {3} on {4}'.format(from_user_name, from_user_phone_no, str(-pairwise_udhar[pair_id]), event_detail, event_time)
    image = 'http://images.clipartpanda.com/rejection-clipart-k4040162.jpg'

    try:
        sendTokenNotification(to_fcm_token, title, body, image)
    except:
        pass
    notification_details(user_phone_to, title, body)

    return _response(True, 'Udhar rejected!', '')



@app.route('/pay', methods = ["POST"])
def pay():
    input = request.get_json()
    try:
        payer_number = input["payer_number"]
        reciever_number = input["reciever_number"]
        amount = input["amount"]

    except:
        return _response(False, 'incorrect format', '')
    
    if amount < 0:
        return _response(False, 'incorrect format', '')
    
    user_id_to_user_id_from_concat = payer_number + reciever_number
    pair_id_user_id_to_user_id_from = hashlib.md5(user_id_to_user_id_from_concat.encode()).hexdigest()

    q1 = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE pair_id = %s'
    r1 = session.execute(q1, [pair_id_user_id_to_user_id_from])

    if len(r1.current_rows) > 0 and r1.current_rows[0][0] is not None:
        amount_to_be_taken = r1.current_rows[0][0]
    else:
        return _response(False,'Data not found in database', '')

    user_id_from_user_id_to_concat = reciever_number + payer_number
    pair_id_user_id_from_user_id_to = hashlib.md5(user_id_from_user_id_to_concat.encode()).hexdigest()

    q2 = 'SELECT total_amount FROM udhar_kharcha.split_bills WHERE pair_id = %s'
    r2 = session.execute(q2, [pair_id_user_id_from_user_id_to])

    if len(r2.current_rows) > 0 and r2.current_rows[0][0] is not None:
        amount_to_be_given = r2.current_rows[0][0]
    else:
        return _response(False,'Data not found in database', '')

    settle_amount = amount_to_be_given-amount_to_be_taken
    if settle_amount < 0 or amount > settle_amount:
        return _response(False,'inconsistent pay', '')
    
    try:
        query = SimpleStatement('UPDATE udhar_kharcha.split_bills SET total_amount = 0 WHERE pair_id = %s', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [pair_id_user_id_to_user_id_from])

        amount_left = settle_amount - amount

        query = SimpleStatement('UPDATE udhar_kharcha.split_bills SET total_amount = %s WHERE pair_id = %s', consistency_level = ConsistencyLevel.LOCAL_QUORUM)
        result = session.execute(query, [amount_left, pair_id_user_id_from_user_id_to])
    except:
        return _response(False, 'DB error', '')

    from_user_id = hashlib.md5(payer_number.encode()).hexdigest()
    to_user_id = hashlib.md5(reciever_number.encode()).hexdigest()

    try:
        query = 'SELECT phone_no, username FROM udhar_kharcha.user_profile WHERE user_id = %s'
        result = session.execute(query, [from_user_id])
        result = result.one()
        from_user_name = result.username

        query = 'SELECT fcm_token FROM udhar_kharcha.fcm_mapping WHERE user_id = %s'
        result = session.execute(query, [to_user_id])
        result = result.one()
        to_fcm_token = result.fcm_token
    except:
        return _response(False, 'DB error', '')

    title = 'Payment Settlement'
    body = '{0} ({1}) has paid you \u20B9 {2}. Remaining balance \u20B9 {3}'.format(from_user_name, payer_number, str(amount), str(amount_left))
    image = 'http://images.clipartpanda.com/rejection-clipart-k4040162.jpg'

    try:
        sendTokenNotification(to_fcm_token, title, body, image)
    except:
        pass
    try:
        notification_details(reciever_number, title, body)
    except:
        pass
    return _response(True, 'udhar amount settled', '')
    

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

    not_available = list()

    for user_phone_no in participants_amount_on_bill:
        user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

        query = "SELECT user_id FROM udhar_kharcha.user_profile WHERE user_id = %s"
        response = session.execute(query, [user_id])

        if len(response.current_rows) == 0:
            not_available.append(user_phone_no)
            
    if len(not_available) != 0:
        return _response(False, "Some users involved in the split are not signed up", not_available)

    for user_phone_no in participants_amount_on_bill:
        count = 0
        while count < 5:
            response = add_personal_expense(user_phone_no, participants_amount_on_bill[user_phone_no], event_name)
            response = json.loads(response.response[0].decode("utf-8"))
            if response["success"]:
                count = 4
            count += 1

    
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
                    to_user_id = hashlib.md5(users_givers[udhar_givers_participants[i][j]].encode()).hexdigest()
                    from_user_id = hashlib.md5(users_takers[udhar_takers_participants[i][k]].encode()).hexdigest()


                    query = SimpleStatement("INSERT INTO udhar_kharcha.split_bills (event_ids, to_user_id, pair_id, from_user_id, total_amount) VALUES (%s, %s, %s, %s, %s) IF NOT EXISTS", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    results = session.execute(query, ([event_id], to_user_id, pair_id, from_user_id, 0))

                    #When searching by primary key "ALLOW FILTERING" is NOT required

                    query = SimpleStatement("SELECT username, phone_no FROM udhar_kharcha.user_profile WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    result = session.execute(query, [to_user_id])
                    result = result.one()
                    from_user_name, from_user_phone_no = result.username, result.phone_no

                    query = SimpleStatement("SELECT fcm_token FROM udhar_kharcha.fcm_mapping WHERE user_id = %s", consistency_level = ConsistencyLevel.LOCAL_QUORUM)
                    result = session.execute(query, [from_user_id])
                    result = result.one()
                    to_fcm_token = result.fcm_token

                    #CONFUSION
                    #sendTokenNotification(to_fcm_token, from_user_name, from_user_phone_no, 30)

                except:
                    return _response(False, 'DB error', '')

                
                if udhar_givers[udhar_givers_participants[i][j]] >= udhars_takers[udhar_takers_participants[i][k]]:
                    pairwise_udhar[pair_id] = -udhars_takers[udhar_takers_participants[i][k]]
                    udhar_givers[udhar_givers_participants[i][j]] -= udhars_takers[udhar_takers_participants[i][k]]
                    k += 1
                else:
                    pairwise_udhar[pair_id] = -udhar_givers[udhar_givers_participants[i][j]]
                    udhars_takers[udhar_takers_participants[i][k]] -= udhar_givers[udhar_givers_participants[i][j]]
                    udhar_givers[udhar_givers_participants[i][j]] = 0

                title = 'New Debt'
                body = '{0} ({1}) requested you to pay \u20B9 {2} for {3} on {4}'.format(from_user_name, from_user_phone_no, str(-pairwise_udhar[pair_id]), event_name, event_time.strftime("%b %d, %Y"))
                image = 'https://aseemrastogi2.files.wordpress.com/2014/01/debt-management.jpg'


                try:
                    sendTokenNotification(to_fcm_token, title, body, image)
                except:
                    pass
                # redirect(url_for('notification_details', user_phone_no = user_from, notification_title = title, notification_body = body))
                notification_details(user_from, title, body)

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

    query = 'SELECT phone_no, username FROM udhar_kharcha.user_profile WHERE user_id = %s'

    for user in r1.current_rows:
        result = session.execute(query, [user[0]])
        result = result.one()
        user_udhars[result.phone_no] = [result.username, user[1]]
    for user in r2.current_rows:
        result = session.execute(query, [user[0]])
        result = result.one()
        if result.phone_no in user_udhars:
            user_udhars[result.phone_no] = [result.username, user_udhars[result.phone_no][1] - user[1]]
        else:
            user_udhars[result.phone_no] = [result.username, -user[1]]  

    return _response(True, "All udhar for input user", user_udhars)



def add_personal_expense(user_phone_no = None, amount = None, event_detail = None):
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


@app.route('/personal_expense', methods=["POST"])
def personal_expense():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
        amount = input["amount"]
        event_detail = input["event_detail"]
    except:
        return _response(False, 'incorrect format', '')

    return add_personal_expense(user_phone_no, amount, event_detail)



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

        phone_to_username = dict()

        query = "SELECT username FROM udhar_kharcha.user_profile WHERE user_id = %s"

        for user_phone_no in dict(response.event_bill):
            user_id = hashlib.md5(user_phone_no.encode()).hexdigest()
            response_ = session.execute(query, [user_id])
            try:
                phone_to_username[user_phone_no] = response_.one().username
            except:
                pass

        data = {'event_bill': dict(response.event_bill), 'event_payers': dict(response.event_payers), 'phone_to_username': phone_to_username}

        dictionary = {'success' : True , 'message' : "Event details of input event" , 'data' : data}
        return dictionary
    except:
        return _response(False, 'DB error', '')



# @app.route('/notification_details/<user_phone_no>/<notification_title>/<notification_body>')
def notification_details(user_phone_no, notification_title, notification_body):
    # if(request.method == "POST"):
    #     input = request.get_json()
    #     try:
    #         user_phone_no = input["user_phone_no"]
    #         notification_title = input["notification_title"]
    #         notification_body = input["notification_body"]
    #     except:
    #         return _response(False, 'incorrect format', '')


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
            try:
                notification_response = session.execute(query, [notification_id])
                notification_response = notification_response.one()
                user_notifications.append([notification_response.notification_title, notification_response.notification_body, notification_response.notification_time])
            except:
                continue
    except:
        pass

    return _response(True, "All personal expenses for input user", user_notifications)

def find_higher_index(event_ids, end_date):
    low, high = 0, len(event_ids)-1
    query = "SELECT event_time FROM udhar_kharcha.event_details WHERE event_id = %s"

    higher_index = -1

    while low <= high:
        mid = low + ((high-low)//2)

        response = session.execute(query, [event_ids[mid]])

        if response.one().event_time.date() > end_date:
            high = mid - 1
        else:
            higher_index = mid
            low = mid + 1

    return higher_index

def find_lower_index(event_ids, start_date):
    low, high = 0, len(event_ids)-1
    query = "SELECT event_time FROM udhar_kharcha.event_details WHERE event_id = %s"

    lower_index = -1

    while low <= high:
        mid = low + ((high-low)//2)

        response = session.execute(query, [event_ids[mid]])

        if response.one().event_time.date() < start_date:
            low = mid + 1
        else:
            lower_index = mid
            high = mid - 1

    return lower_index

@app.route('/analytics', methods = ["POST"])
def analytics():
    input = request.get_json()
    try:
        user_phone_no = input["user_phone_no"]
        type = input["type"] # "weekly" or "monthly"
        if type != "weekly" and type != "monthly":
            raise Exception
    except:
        return _response(False, 'incorrect format', '')

    user_id = hashlib.md5(user_phone_no.encode()).hexdigest()

    query = "SELECT event_ids FROM udhar_kharcha.personal_expenses WHERE user_id = %s"
    count = 0
    while count < 3:
        try:
            response = session.execute(query, [user_id])
            count = 3
        except:
            count += 1
            continue
    
    isExpensePresent = True

    try:
        event_ids = response.one().event_ids
    except:
        isExpensePresent = False

    if type == "weekly":

        if not isExpensePresent:
            return _response(True, 'Weekly Events', {'total_expense': 0.0, 'weekly_events_and_expense': []})

        no_of_weeks_used_in_analytics = 5

        today = date.today()

        lower_index = find_lower_index(event_ids, today + relativedelta(weekday=MO(-no_of_weeks_used_in_analytics)))
        if lower_index != -1:
            higher_index = find_higher_index(event_ids, today)

        time_range_to_events = [None]*no_of_weeks_used_in_analytics
        total_expense = 0.0
        
        query = "SELECT event_detail, event_time, event_bill FROM udhar_kharcha.event_details WHERE event_id = %s"

        events_list = []
        weekly_expense = 0.0

        for i in range(-no_of_weeks_used_in_analytics, 0, 1):
            start_date = today + relativedelta(weekday=MO(i))
            end_date = min(start_date + timedelta(days=6), today)

            time_range = [start_date, end_date]

            time_range_to_events[i+no_of_weeks_used_in_analytics] = [time_range, [], 0]

            if lower_index == -1 or (len(events_list) > 0 and events_list[-1][1].date() > end_date):
                continue

            breaked = False

            while lower_index <= higher_index:
                count = 0
                while count < 3:
                    try:
                        response = session.execute(query, [event_ids[lower_index]])
                        count = 3
                    except:
                        count += 1
                        continue
                
                try:
                    response = response.one()
                except:
                    return _response(False, 'DB error', '')

                if response.event_time.date() > end_date:
                    time_range_to_events[i+no_of_weeks_used_in_analytics] = [time_range, events_list, weekly_expense]
                    total_expense += weekly_expense
                    events_list = [[response.event_detail, response.event_time, dict(response.event_bill)[user_phone_no]]]
                    weekly_expense = dict(response.event_bill)[user_phone_no]
                    lower_index += 1
                    breaked = True
                    break
                else:
                    events_list.append([response.event_detail, response.event_time, dict(response.event_bill)[user_phone_no]])
                    weekly_expense += dict(response.event_bill)[user_phone_no]

                lower_index += 1

            if not breaked:
                time_range_to_events[i+no_of_weeks_used_in_analytics] = [time_range, events_list, weekly_expense]
                total_expense += weekly_expense
                events_list = []
                weekly_expense = 0.0

        response = {'total_expense': total_expense, 'weekly_events_and_expense': time_range_to_events}

        return _response(True, 'Weekly Events', response)

    if type == "monthly":

        if not isExpensePresent:
            return _response(True, 'Monthly Events', {'total_expense': 0.0, 'monthly_events_and_expense': []})

        today = date.today()

        no_of_months_used_in_analytics = 6

        last_day_of_month = today
        first_day_of_month = today.replace(day=1)

        time_range_to_events = [None]*no_of_months_used_in_analytics

        time_range_to_events[-1] = [[first_day_of_month, last_day_of_month], [], 0]

        for i in range(no_of_months_used_in_analytics-2, -1, -1):
            last_day_of_month = first_day_of_month - timedelta(days=1)
            first_day_of_month = last_day_of_month.replace(day=1)
            time_range_to_events[i] = [[first_day_of_month, last_day_of_month], [], 0]

        lower_index = find_lower_index(event_ids, time_range_to_events[0][0][0])
        if lower_index != -1:
            higher_index = find_higher_index(event_ids, today)

        total_expense = 0.0
        
        query = "SELECT event_detail, event_time, event_bill FROM udhar_kharcha.event_details WHERE event_id = %s"

        events_list = []
        monthly_expense = 0.0
    
        for i in range(no_of_months_used_in_analytics):
            start_date = time_range_to_events[i][0][0]
            end_date = time_range_to_events[i][0][1]

            time_range = [start_date, end_date]

            if lower_index == -1 or (len(events_list) > 0 and events_list[-1][1].date() > end_date):
                continue

            breaked = False

            while lower_index <= higher_index:
                count = 0
                while count < 3:
                    try:
                        response = session.execute(query, [event_ids[lower_index]])
                        count = 3
                    except:
                        count += 1
                        continue
                
                try:
                    response = response.one()
                except:
                    return _response(False, 'DB error', '')

                if response.event_time.date() > end_date:
                    time_range_to_events[i] = [time_range, events_list, monthly_expense]
                    total_expense += monthly_expense
                    events_list = [[response.event_detail, response.event_time, dict(response.event_bill)[user_phone_no]]]
                    monthly_expense = dict(response.event_bill)[user_phone_no]
                    lower_index += 1
                    breaked = True
                    break
                else:
                    events_list.append([response.event_detail, response.event_time, dict(response.event_bill)[user_phone_no]])
                    monthly_expense += dict(response.event_bill)[user_phone_no]

                lower_index += 1

            if not breaked:
                time_range_to_events[i] = [time_range, events_list, monthly_expense]
                total_expense += monthly_expense
                events_list = []
                monthly_expense = 0.0

        response = {'total_expense': total_expense, 'monthly_events_and_expense': time_range_to_events}

        return _response(True, 'Monthly Events', response)

if __name__ == '__main__':
    app.run(debug = True, threaded = True)