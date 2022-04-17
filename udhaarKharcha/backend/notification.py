from turtle import color
import firebase_admin
from firebase_admin import credentials, messaging

credential = credentials.Certificate('/home/shubham/Desktop/Desktop/Courses/Computer-System-Design/Project/udahriApp/udhaarKharcha/backend/firebase.json')
firebase_admin.initialize_app(credential)

def sendTokenNotification(fcm_token, title, body, image):
    message = messaging.Message(
        token=fcm_token,
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                title=title,
                body=body,
                # image=image,
                color='#f45342',
                click_action='FLUTTER_NOTIFICATION_CLICK'
            )
        ),
        data={
            'route': 'login'
        }
    )
    response = messaging.send(message)
    print('Successfully sent message:', response)

def sendTopicNotification(topic = 'analytics'):

    title = 'Check your Analyses'
    body = 'Your analytics for previous month is ready \nTap to view'
    # image = 'https://aseemrastogi2.files.wordpress.com/2014/01/debt-management.jpg'

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
                # image=image,
                color='#f45342',
                click_action='FLUTTER_NOTIFICATION_CLICK'
            )
        )
    )

    response = messaging.send(message)
    print('Successfully sent message:', response)

sendTokenNotification('cJiOesCZTpyBI2NOu4Xnw1:APA91bFQOhklbMVhC7aDlQBdqYqCpz_5j-QiURXJ6wX5uZHmO31vJ8AAhplmnQnJlqSnrHckhKxfCxxWp4nCvzxgOAUkizLNj5ygrd_XIZCM9WDANd_DpJfmrFXKKK4sc7GMMGqlv2Kq', 'new debt', 'eijisefise', 'https://www.clipartmax.com/png/middle/157-1575710_open-approve-icon.png')