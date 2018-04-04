<%-- 
    Document   : SparkPlugs
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
    public class SparkPlugs{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetSparkPlugsTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSSparkPlugsTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDSparkPlugsTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> SparkPlugsColumns = new HashMap<String, Integer>();
        Map<String, Integer> SparkPlugsColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> SparkPlugsColumnsText = new HashMap<String, String>();

        SparkPlugs(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetSparkPlugsTable = TruckingConnection.prepareStatement("SELECT * FROM spark_plugs WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSSparkPlugsTable = GetSparkPlugsTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDSparkPlugsTable = RSSparkPlugsTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSparkPlugsTable.getColumnCount(); MetaIndex++){
                    SparkPlugsColumns.put(MDSparkPlugsTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSparkPlugsTable.getColumnCount(); MetaIndex++){
                    SparkPlugsColumns.put(MDSparkPlugsTable.getColumnName(MetaIndex), MetaIndex);
                    SparkPlugsColumnsPrecision.put(MDSparkPlugsTable.getColumnName(MetaIndex), MDSparkPlugsTable.getPrecision(MetaIndex));
                    SparkPlugsColumnsText.put(MDSparkPlugsTable.getColumnName(MetaIndex), 
                        MDSparkPlugsTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getSparkPlugsTable(){
            try{
                RSSparkPlugsTable = GetSparkPlugsTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSSparkPlugsTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        SparkPlugs UserAccountInfo = new SparkPlugs(vehicle_id_param);
        Map<String, String> NewSparkPlugsInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet SparkPlugsTable = UserAccountInfo.getSparkPlugsTable();
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
        for (String key : UserAccountInfo.SparkPlugsColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.SparkPlugsColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.SparkPlugsColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("spark_plugs_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewSparkPlugsInput.put(key,request.getParameter(UserAccountInfo.SparkPlugsColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddSparkPlugsRecord = "INSERT INTO spark_plugs (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.SparkPlugsColumnsText.keySet()){
                if(key.equals("spark_plugs_id") == false) {
                    AddSparkPlugsRecord = AddSparkPlugsRecord + key + ",";
                }
            }
            
            AddSparkPlugsRecord = AddSparkPlugsRecord.substring(0, AddSparkPlugsRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.SparkPlugsColumnsText.keySet()){
                if((key.equals("spark_plugs_id") == false) && (key.equals("vehicle_id") == false)){
                    AddSparkPlugsRecord = AddSparkPlugsRecord + "'" + NewSparkPlugsInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddSparkPlugsRecord = AddSparkPlugsRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddSparkPlugsRecord = AddSparkPlugsRecord.substring(0, AddSparkPlugsRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.SparkPlugsColumnsText.keySet()){
                if(key.equals("spark_plugs_id") == false){
                    AddSparkPlugsRecord = AddSparkPlugsRecord + "'" + NewSparkPlugsInput.get(key) + "',";
                }
            }
*/
            AddSparkPlugsRecord = AddSparkPlugsRecord.substring(0, AddSparkPlugsRecord.length() - 1) + ")";
            PreparedStatement AddSparkPlugsRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddSparkPlugsRecord);
            test = AddSparkPlugsRecordStatement.executeUpdate();
            SparkPlugsTable = UserAccountInfo.getSparkPlugsTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(SparkPlugsTable.next()){
                    UpdateStatement = "UPDATE spark_plugs SET";
                    MakeChange = false;
                    RowID = SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get("spark_plugs_id"));
                    for(String key : UserAccountInfo.SparkPlugsColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.SparkPlugsColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.SparkPlugsColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE spark_plugs_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                SparkPlugsTable = UserAccountInfo.getSparkPlugsTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Spark Plugs</title>
    </head>
    <body>
        <h1>Spark Plugs</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="SparkPlugsGetter" action="SparkPlug.jsp" method="POST">
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
                        <th><%=UserAccountInfo.SparkPlugsColumnsText.get("spark_plugs_id")%></th>
                        <th><%=UserAccountInfo.SparkPlugsColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.SparkPlugsColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(SparkPlugsTable.next()){%>
                                <tr>
                                    <td><%=SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get("spark_plugs_id"))%></td>
                                    <td><%=SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDSparkPlugsTable.getPrecision(UserAccountInfo.SparkPlugsColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get("spark_plugs_id"))%> <%=UserAccountInfo.MDSparkPlugsTable.getColumnName(UserAccountInfo.SparkPlugsColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=SparkPlugsTable.getString(UserAccountInfo.SparkPlugsColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="SparkPlug.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= SparkPlugsTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDSparkPlugsTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.SparkPlugsColumnsText.get(UserAccountInfo.MDSparkPlugsTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="SparkPlug.jsp" method="POST">
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

