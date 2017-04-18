## Web app for Database II project
### Master Degree in Computer Science @ University of Bari

#### Required
- maven
- python (or other stuff to run client)


#### Run application
- Import db into postgres (dbname: farmacia, user: farmacista, password: farmacista)
- Go with terminal  into bdii-server directory and type `mvn exec:java -Dexec.mainClass="Server"`
- Go with termina into bdii-client/app and type `python -mSimpleHTTPServer`
- Open your browser (app tested on Google Chrome): http://localhost:8000/
- Enjoy
