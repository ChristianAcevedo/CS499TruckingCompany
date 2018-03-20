<%-- 
    Document   : PersonnelData
    Created on : Feb 9, 2018, 1:24:52 PM
    Author     : Owner
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSetMetaData"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<!DOCTYPE html>

<%!
    public class PersonnelData{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetPersonnelDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSPersonnelDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDPersonnelDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> PersonnelDataColumns = new HashMap<String, Integer>();

        Map<String, String> PersonnelDataColumnsText = new HashMap<String, String>();

        PersonnelData(){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetPersonnelDataTable = TruckingConnection.prepareStatement("SELECT * FROM personnel_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSPersonnelDataTable = GetPersonnelDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDPersonnelDataTable = RSPersonnelDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDPersonnelDataTable.getColumnCount(); MetaIndex++){
                    PersonnelDataColumns.put(MDPersonnelDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDPersonnelDataTable.getColumnCount(); MetaIndex++){
                    PersonnelDataColumns.put(MDPersonnelDataTable.getColumnName(MetaIndex), MetaIndex);
                    PersonnelDataColumnsText.put(MDPersonnelDataTable.getColumnName(MetaIndex), 
                        MDPersonnelDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }

        }

        public ResultSet getCookiesTable(){
            try{
                RSCookiesTable = GetCookiesTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSCookiesTable;   
        }

        public ResultSet getSignInDataTable(){
            try{
                RSSignInDataTable = GetSignInDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSSignInDataTable;   
        }

        public ResultSet getPersonnelDataTable(){
            try{
                RSPersonnelDataTable = GetPersonnelDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSPersonnelDataTable;   
        }
}
%>

<%
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        PersonnelData UserAccountInfo = new PersonnelData();
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet PersonnelDataTable = UserAccountInfo.getPersonnelDataTable();
        Cookie cookies[] = request.getCookies();

        if(cookies != null){
            try{
                while(CookiesTable.next()){
                    for(Cookie c : cookies){
                        if(c.getName().equals(CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_name"))) &&
                                c.getValue().equals(CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_value")))){
                            SignedIn = true;
                            UserName = CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("user_name"));
                            UserID = CookiesTable.getString(UserAccountInfo.UserCookiesColumns.get("cookie_id"));    
                        }
                    }
                }
                while(SignInDataTable.next()){
                    if(SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("user_name")).equals(UserName)){
                        AccessCode = SignInDataTable.getString(UserAccountInfo.SignInDataColumns.get("access_code"));
                    }
                }
            }catch(SQLException ex){
                ex.printStackTrace();
            }
        }
        
        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }else if(AccessCode.contains("S") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }
        
/*        if(AccessCode.contains("P") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }

        if(SignedIn == false){
            response.sendRedirect("index.jsp");
        }
*/
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Personnel Data</title>
    </head>
    <body>
        <h1>Personnel Data</h1>
        <table border="1">
            <thead>
                <tr>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("personnel_id")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("first_name")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("middle_name")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("last_name")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("street_address")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("city")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("state")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("zip")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("home_phone")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("cell_phone")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("pay")%></th>
                    <th><%=UserAccountInfo.PersonnelDataColumnsText.get("years_with_company")%></th>
                </tr>
            </thead>
            <tbody>
                <%try{
                    while(PersonnelDataTable.next()){%>
                        <tr>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("first_name"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("middle_name"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("last_name"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("street_address"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("city"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("state"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("zip"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("home_phone"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("cell_phone"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("pay"))%></td>
                            <td><%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("years_with_company"))%></td>
                        </tr> 
                    <%}%>
                <%}catch(SQLException ex){
                    ex.printStackTrace();
                }%>  
            </tbody>
        </table>
        <form name="PrintMonthlyPayrollReport" action="" method="POST">
            <tr>
                <td><input type="submit" value="Print Monthly Payroll Report" name="PrintMonthlyPayrollReport" style="width: 200px;"/></td>
            </tr>
        </form>
            <a href="jasperMonthlyPayrollReport.jsp">Monthly Payroll Report</a>
    </body>
</html>
