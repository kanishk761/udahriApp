from turtle import color
import firebase_admin
from firebase_admin import credentials, messaging

def sendNotification(token, user_from, amount):
    credential = credentials.Certificate('/home/shubham/Desktop/Desktop/Courses/Computer-System-Design/Project/udahriApp/udhaarKharcha/backend/firebase.json')
    firebase_admin.initialize_app(credential)

    registration_token = 'cb_LxhqxQGGbyA3wSO4_0D:APA91bG5vJrNxEunpmY09eoQtgFYjL8ClomYRyuqC9AIJBZxbhPlp8pvqYT9qKGWtLDHnlabjyzNzJRi5VWeE5RSQr2bvBLZ56yL9gi7V8Djao3qxbe8vTzmVfZUm4E3i5H7aT4uH0-Z'

    title = 'New Debt'
    body = '{0} requested you to pay {1}'.format(user_from, str(amount))
    image = 'https://aseemrastogi2.files.wordpress.com/2014/01/debt-management.jpg'

    topic = 'analytics'

    # message = messaging.Message(token=registration_token, notification = notification, data = {'route', 'login'})

    message = messaging.Message(
        topic=topic, 
        data={
            'screen': 'launch_analytics_page'
        }, 
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                title=title,
                body=body,
                image=image,
                color='#f45342',
                click_action='FLUTTER_NOTIFICATION_CLICK'
            )
        )
    )

    response = messaging.send(message)
    print('Successfully sent message:', response)

sendNotification('', 'Shubham', 40)