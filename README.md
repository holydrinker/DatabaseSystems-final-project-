## Web app for Database Systems II project
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


#### Navigate datawarehouse
- Download and install Apache Tomcat 7
- Download and extract Mondrian directory from here (http://www.di.uniba.it/~ceci/micFiles/courses/bdii/2011-2012/Lab/b-foodmart%20e%20mondrian.zip)
- Copy Mondrian directory into Tomcat/webapps
- Go into my directory database/dw and copy farmacia.xml and farmacia.jsp into Tomcat/webapps/mondrian/WEB-INF/queries
- Run tomcat (default port 8080)
- Open your browser (tested on Google Chrome): http://localhost:8080/mondrian/testpage.jsp?query=farmacia
- Enjoy
