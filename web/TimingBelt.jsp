<%-- 
    Document   : TimingBelt
    Created on : Feb 9, 2018, 1:22:43 PM
    Author     : Mr. Mango
--%>

<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
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
    public class TimingBelt{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetTimingBeltTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSTimingBeltTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDTimingBeltTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> TimingBeltColumns = new HashMap<String, Integer>();
        Map<String, Integer> TimingBeltColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> TimingBeltColumnsText = new HashMap<String, String>();

        TimingBelt(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetTimingBeltTable = TruckingConnection.prepareStatement("SELECT * FROM timing_belt WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSTimingBeltTable = GetTimingBeltTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDTimingBeltTable = RSTimingBeltTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTimingBeltTable.getColumnCount(); MetaIndex++){
                    TimingBeltColumns.put(MDTimingBeltTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDTimingBeltTable.getColumnCount(); MetaIndex++){
                    TimingBeltColumns.put(MDTimingBeltTable.getColumnName(MetaIndex), MetaIndex);
                    TimingBeltColumnsPrecision.put(MDTimingBeltTable.getColumnName(MetaIndex), MDTimingBeltTable.getPrecision(MetaIndex));
                    TimingBeltColumnsText.put(MDTimingBeltTable.getColumnName(MetaIndex), 
                        MDTimingBeltTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getTimingBeltTable(){
            try{
                RSTimingBeltTable = GetTimingBeltTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSTimingBeltTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        TimingBelt UserAccountInfo = new TimingBelt(vehicle_id_param);
        Map<String, String> NewTimingBeltInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet TimingBeltTable = UserAccountInfo.getTimingBeltTable();
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
        }else if(AccessCode.contains("E") == false){
            response.sendRedirect("UserSignedIn.jsp");
        }
        

        
        
        
        boolean GoodInput = true;
        for (String key : UserAccountInfo.TimingBeltColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.TimingBeltColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.TimingBeltColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("timing_belt_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewTimingBeltInput.put(key,request.getParameter(UserAccountInfo.TimingBeltColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddTimingBeltRecord = "INSERT INTO timing_belt (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.TimingBeltColumnsText.keySet()){
                if(key.equals("timing_belt_id") == false) {
                    AddTimingBeltRecord = AddTimingBeltRecord + key + ",";
                }
            }
            
            AddTimingBeltRecord = AddTimingBeltRecord.substring(0, AddTimingBeltRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TimingBeltColumnsText.keySet()){
                if((key.equals("timing_belt_id") == false) && (key.equals("vehicle_id") == false)){
                    AddTimingBeltRecord = AddTimingBeltRecord + "'" + NewTimingBeltInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddTimingBeltRecord = AddTimingBeltRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddTimingBeltRecord = AddTimingBeltRecord.substring(0, AddTimingBeltRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.TimingBeltColumnsText.keySet()){
                if(key.equals("timing_belt_id") == false){
                    AddTimingBeltRecord = AddTimingBeltRecord + "'" + NewTimingBeltInput.get(key) + "',";
                }
            }
*/
            AddTimingBeltRecord = AddTimingBeltRecord.substring(0, AddTimingBeltRecord.length() - 1) + ")";
            PreparedStatement AddTimingBeltRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddTimingBeltRecord);
            test = AddTimingBeltRecordStatement.executeUpdate();
            TimingBeltTable = UserAccountInfo.getTimingBeltTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(TimingBeltTable.next()){
                    UpdateStatement = "UPDATE timing_belt SET";
                    MakeChange = false;
                    RowID = TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get("timing_belt_id"));
                    for(String key : UserAccountInfo.TimingBeltColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.TimingBeltColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.TimingBeltColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE timing_belt_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                TimingBeltTable = UserAccountInfo.getTimingBeltTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Timing Belt Checks</title>
    </head>
    <body>
        <h1>Timing Belt Checks</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="TimingBeltGetter" action="TimingBelt.jsp" method="POST">
            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
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
                        <th><%=UserAccountInfo.TimingBeltColumnsText.get("timing_belt_id")%></th>
                        <th><%=UserAccountInfo.TimingBeltColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.TimingBeltColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(TimingBeltTable.next()){%>
                                <tr>
                                    <td><%=TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get("timing_belt_id"))%></td>
                                    <td><%=TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDTimingBeltTable.getPrecision(UserAccountInfo.TimingBeltColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get("timing_belt_id"))%> <%=UserAccountInfo.MDTimingBeltTable.getColumnName(UserAccountInfo.TimingBeltColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=TimingBeltTable.getString(UserAccountInfo.TimingBeltColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="TimingBelt.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= TimingBeltTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDTimingBeltTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.TimingBeltColumnsText.get(UserAccountInfo.MDTimingBeltTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="TimingBelt.jsp" method="POST">
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
    </body>
</html>

<script>
    function myFunction() {
        var txt = "Refreshing Vehicle Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>

