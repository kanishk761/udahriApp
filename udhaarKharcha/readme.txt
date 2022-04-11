scp -i udhar_kharcha_final.pem -r requirements.sh 000-default.conf backend/app.py backend/flaskapp.wsgi backend/sf-class2-root.crt ubuntu@ec2-3-111-196-101.ap-south-1.compute.amazonaws.com:/home/ubuntu/


curl -X GET http://ec2-43-204-23-206.ap-south-1.compute.amazonaws.com/
