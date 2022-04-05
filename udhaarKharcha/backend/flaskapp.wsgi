#flaskapp.wsgi
import sys
sys.path.insert(0, '/var/www/html/flaskapp')
#sys.path.insert(1, '/home/shubham/Desktop/Desktop/Courses/Computer-System-Design/Project/udahriApp/udhaarKharcha/backend/lib/python3.8/site-packages')

from app import app as application
