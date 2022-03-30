from flask import *
from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
from cassandra.policies import WhiteListRoundRobinPolicy, DowngradingConsistencyRetryPolicy
from cassandra.query import SimpleStatement, tuple_factory
from cassandra import ConsistencyLevel
import hashlib

app = Flask(__name__)

profile = ExecutionProfile(
    load_balancing_policy = WhiteListRoundRobinPolicy(['127.0.0.1']),
    retry_policy = DowngradingConsistencyRetryPolicy(),
    consistency_level = ConsistencyLevel.QUORUM,
    serial_consistency_level = ConsistencyLevel.SERIAL,
    request_timeout = 15,
    row_factory = tuple_factory
)

cluster = Cluster()
session = cluster.connect() #execution_profiles = profile)

session.set_keyspace('udhar_kharcha')

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

@app.route('/personal_expense', methods=["POST"])
def personal_expense():
    input = request.get_json()
    try:
        

if __name__ == '__main__':
    app.run(debug = True, threaded = True)




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