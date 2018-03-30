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
        Map<String, String> NewPersonnelDataInput = new HashMap<String, String>();
        
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
        

        
        
        
        
        
        boolean GoodInput = true;
        for (String key : UserAccountInfo.PersonnelDataColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.PersonnelDataColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.PersonnelDataColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("personnel_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewPersonnelDataInput.put(key,request.getParameter(UserAccountInfo.PersonnelDataColumnsText.get(key) + " INPUT"));
            }
        }
        int test = 0;
        String AddPersonnelRecord = "INSERT INTO personnel_data (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.PersonnelDataColumnsText.keySet()){
                if(key.equals("personnel_id") == false){
                    AddPersonnelRecord = AddPersonnelRecord + key + ",";
                }
            }
            AddPersonnelRecord = AddPersonnelRecord.substring(0, AddPersonnelRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.PersonnelDataColumnsText.keySet()){
                if(key.equals("personnel_id") == false){
                    AddPersonnelRecord = AddPersonnelRecord + "'" + NewPersonnelDataInput.get(key) + "',";
                }
            }
            AddPersonnelRecord = AddPersonnelRecord.substring(0, AddPersonnelRecord.length() - 1) + ")";
            PreparedStatement AddPersonnelRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddPersonnelRecord);
            test = AddPersonnelRecordStatement.executeUpdate();
            PersonnelDataTable = UserAccountInfo.getPersonnelDataTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(PersonnelDataTable.next()){
                    UpdateStatement = "UPDATE personnel_data SET";
                    MakeChange = false;
                    RowID = PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"));
                    for(String key : UserAccountInfo.PersonnelDataColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.PersonnelDataColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.PersonnelDataColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE personnel_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                PersonnelDataTable = UserAccountInfo.getPersonnelDataTable();
            }
        }
        
        
        
        
        

        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Personnel Data</title>
    </head>
    <body>
        <h1>Personnel Data</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="PersonnelDataGetter" action="PersonnelData.jsp" method="POST">
            <table border="0">
                <tbody>
                    <tr>
                        <td>
                            <select name="RefreshUpdate">
                                <option value="Refresh">Refresh Page</option>
                                <option value="Update">Update Page</option>
                            </select>
                        </td>
                        <td><input type="submit" value="View/Update Data" onclick="myFunction()"/></td>
                    </tr>
                </tbody>
            </table>
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
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("personnel_id")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("first_name"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("first_name")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("first_name"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("middle_name"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("middle_name")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("middle_name"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("last_name"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("last_name")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("last_name"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("street_address"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("street_address")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("street_address"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("city"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("city")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("city"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("state"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("state")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("state"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("zip"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("zip")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("zip"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("home_phone"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("home_phone")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("home_phone"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("cell_phone"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("cell_phone")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("cell_phone"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("pay"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("pay")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("pay"))%>"/></td>
                                <td><input style="width: <%=UserAccountInfo.MDPersonnelDataTable.getPrecision(UserAccountInfo.PersonnelDataColumns.get("years_with_company"))*PixelMultiplier%>px;" type="text" name="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("personnel_id"))%> <%=UserAccountInfo.MDPersonnelDataTable.getColumnName(UserAccountInfo.PersonnelDataColumns.get("years_with_company")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=PersonnelDataTable.getString(UserAccountInfo.PersonnelDataColumns.get("years_with_company"))%>"/></td>
                            </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>
                                        <tr>
                            <form action="PersonnelData.jsp" method="POST">
                                <%for(int MetaIndex = 1; MetaIndex <= PersonnelDataTable.getMetaData().getColumnCount(); MetaIndex++){    
                                    int size = UserAccountInfo.MDPersonnelDataTable.getPrecision(MetaIndex) * PixelMultiplier; %>
                                    <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.PersonnelDataColumnsText.get(UserAccountInfo.MDPersonnelDataTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                                <%}%>
                            </form>
                        </tr>
                </tbody>
            </table>
        </form>
        <form action="PersonnelData.jsp" method="POST">
            <input type="submit" value="Add Data" name="AddDataBtn" />
        </form>
        <form name="PrintMonthlyPayrollReport" action="" method="POST">
            <tr>
                <td><input type="submit" value="Print Monthly Payroll Report" name="PrintMonthlyPayrollReport" style="width: 200px;"/></td>
            </tr>
        </form>
                <form name="DeleteUpdate" action="PersonnelData.jsp" method="POST">
            <table border="0">
                <thead>
                    <tr>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                    </tr>
                </tbody>
            </table>

        </form>
            <a href="jasperMonthlyPayrollReport.jsp">Monthly Payroll Report</a>
    </body>
</html>

<script>
    function myFunction() {
        var txt = "Refreshing Personnel Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>
