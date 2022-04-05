scp -i udhar_kharcha.pem -r requirements.sh 000-default.conf backend/src/app.py backend/src/flaskapp.wsgi backend/src/sf-class2-root.crt ubuntu@ec2-43-204-23-206.ap-south-1.compute.amazonaws.com:/home/ubuntu/


curl -X GET http://ec2-43-204-23-206.ap-south-1.compute.amazonaws.com/
