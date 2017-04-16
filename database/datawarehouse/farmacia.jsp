<%@ page session="true" contentType="text/html; charset=ISO-8859-1" %>
<%@ taglib uri="http://www.tonbeller.com/jpivot" prefix="jp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>


<jp:mondrianQuery id="query01" jdbcDriver="org.postgresql.Driver" jdbcUrl="jdbc:postgresql://localhost/farmacia?user=farmacista&password=farmacista" catalogUri="/WEB-INF/queries/farmacia.xml">
select {[Measures].[quantita]} ON COLUMNS,
  {([Prodotto],[Tempo])} ON ROWS
from [Vendite]

</jp:mondrianQuery>

<c:set var="title01" scope="session">Vendite Farmacia</c:set>
