<%-- 
    Document   : jasperMonthlyPayrollReport
    Created on : Mar 19, 2018, 2:31:19 AM
    Author     : james
--%>

<%@ page contentType="application/pdf" %>
 
<%@ page trimDirectiveWhitespaces="true"%>
 
<%@ page import="net.sf.jasperreports.engine.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="java.io.FileNotFoundException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.SQLException" %>
 
<%
        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;
 
        Class.forName("com.mysql.jdbc.Driver");
        
        TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
 
        String jrxmlFile = session.getServletContext().getRealPath(request.getContextPath())+"/ReportIncomingShippingSummary.jrxml";
        InputStream input = new FileInputStream(new File(jrxmlFile));
 
        JasperReport jasperReport = JasperCompileManager.compileReport(input);
        JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, null, TruckingConnection);
 
        JasperExportManager.exportReportToPdfStream(jasperPrint, response.getOutputStream());
 
%>
