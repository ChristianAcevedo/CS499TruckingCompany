<%-- 
    Document   : LightsCheck
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
    public class LightsCheck{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetLightsCheckTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSLightsCheckTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDLightsCheckTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> LightsCheckColumns = new HashMap<String, Integer>();
        Map<String, Integer> LightsCheckColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> LightsCheckColumnsText = new HashMap<String, String>();

        LightsCheck(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetLightsCheckTable = TruckingConnection.prepareStatement("SELECT * FROM lights_check WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSLightsCheckTable = GetLightsCheckTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDLightsCheckTable = RSLightsCheckTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDLightsCheckTable.getColumnCount(); MetaIndex++){
                    LightsCheckColumns.put(MDLightsCheckTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDLightsCheckTable.getColumnCount(); MetaIndex++){
                    LightsCheckColumns.put(MDLightsCheckTable.getColumnName(MetaIndex), MetaIndex);
                    LightsCheckColumnsPrecision.put(MDLightsCheckTable.getColumnName(MetaIndex), MDLightsCheckTable.getPrecision(MetaIndex));
                    LightsCheckColumnsText.put(MDLightsCheckTable.getColumnName(MetaIndex), 
                        MDLightsCheckTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getLightsCheckTable(){
            try{
                RSLightsCheckTable = GetLightsCheckTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSLightsCheckTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        LightsCheck UserAccountInfo = new LightsCheck(vehicle_id_param);
        Map<String, String> NewLightsCheckInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet LightsCheckTable = UserAccountInfo.getLightsCheckTable();
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
        for (String key : UserAccountInfo.LightsCheckColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.LightsCheckColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.LightsCheckColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("lights_check_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewLightsCheckInput.put(key,request.getParameter(UserAccountInfo.LightsCheckColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddLightsCheckRecord = "INSERT INTO lights_check (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.LightsCheckColumnsText.keySet()){
                if(key.equals("lights_check_id") == false) {
                    AddLightsCheckRecord = AddLightsCheckRecord + key + ",";
                }
            }
            
            AddLightsCheckRecord = AddLightsCheckRecord.substring(0, AddLightsCheckRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.LightsCheckColumnsText.keySet()){
                if((key.equals("lights_check_id") == false) && (key.equals("vehicle_id") == false)){
                    AddLightsCheckRecord = AddLightsCheckRecord + "'" + NewLightsCheckInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddLightsCheckRecord = AddLightsCheckRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddLightsCheckRecord = AddLightsCheckRecord.substring(0, AddLightsCheckRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.LightsCheckColumnsText.keySet()){
                if(key.equals("lights_check_id") == false){
                    AddLightsCheckRecord = AddLightsCheckRecord + "'" + NewLightsCheckInput.get(key) + "',";
                }
            }
*/
            AddLightsCheckRecord = AddLightsCheckRecord.substring(0, AddLightsCheckRecord.length() - 1) + ")";
            PreparedStatement AddLightsCheckRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddLightsCheckRecord);
            test = AddLightsCheckRecordStatement.executeUpdate();
            LightsCheckTable = UserAccountInfo.getLightsCheckTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(LightsCheckTable.next()){
                    UpdateStatement = "UPDATE lights_check SET";
                    MakeChange = false;
                    RowID = LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get("lights_check_id"));
                    for(String key : UserAccountInfo.LightsCheckColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.LightsCheckColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.LightsCheckColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE lights_check_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                LightsCheckTable = UserAccountInfo.getLightsCheckTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lights Check</title>
    </head>
    <body>
        <h1>Lights Check</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="LightsCheckGetter" action="LightsCheck.jsp" method="POST">
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
                        <th><%=UserAccountInfo.LightsCheckColumnsText.get("lights_check_id")%></th>
                        <th><%=UserAccountInfo.LightsCheckColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.LightsCheckColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(LightsCheckTable.next()){%>
                                <tr>
                                    <td><%=LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get("lights_check_id"))%></td>
                                    <td><%=LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDLightsCheckTable.getPrecision(UserAccountInfo.LightsCheckColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get("lights_check_id"))%> <%=UserAccountInfo.MDLightsCheckTable.getColumnName(UserAccountInfo.LightsCheckColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=LightsCheckTable.getString(UserAccountInfo.LightsCheckColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="LightsCheck.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= LightsCheckTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDLightsCheckTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.LightsCheckColumnsText.get(UserAccountInfo.MDLightsCheckTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="LightsCheck.jsp" method="POST">
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

