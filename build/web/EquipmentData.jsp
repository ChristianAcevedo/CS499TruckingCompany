<%-- 
    Document   : EquipmentData
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
    public class EquipmentData{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetEquipmentDataTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSEquipmentDataTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDEquipmentDataTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> EquipmentDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> EquipmentDataColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> EquipmentDataColumnsText = new HashMap<String, String>();

        EquipmentData(){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetEquipmentDataTable = TruckingConnection.prepareStatement("SELECT * FROM equipment_data");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSEquipmentDataTable = GetEquipmentDataTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDEquipmentDataTable = RSEquipmentDataTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDEquipmentDataTable.getColumnCount(); MetaIndex++){
                    EquipmentDataColumns.put(MDEquipmentDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDEquipmentDataTable.getColumnCount(); MetaIndex++){
                    EquipmentDataColumns.put(MDEquipmentDataTable.getColumnName(MetaIndex), MetaIndex);
                    EquipmentDataColumnsPrecision.put(MDEquipmentDataTable.getColumnName(MetaIndex), MDEquipmentDataTable.getPrecision(MetaIndex));
                    EquipmentDataColumnsText.put(MDEquipmentDataTable.getColumnName(MetaIndex), 
                        MDEquipmentDataTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getEquipmentDataTable(){
            try{
                RSEquipmentDataTable = GetEquipmentDataTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSEquipmentDataTable;   
        }
}
%>

<%
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        EquipmentData UserAccountInfo = new EquipmentData();
        Map<String, String> NewEquipmentDataInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
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
        for (String key : UserAccountInfo.EquipmentDataColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.EquipmentDataColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.EquipmentDataColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("equipment_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewEquipmentDataInput.put(key,request.getParameter(UserAccountInfo.EquipmentDataColumnsText.get(key) + " INPUT"));
            }
        }
        int test = 0;
        String AddEquipmentRecord = "INSERT INTO equipment_data (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                if(key.equals("equipment_id") == false){
                    AddEquipmentRecord = AddEquipmentRecord + key + ",";
                }
            }
            AddEquipmentRecord = AddEquipmentRecord.substring(0, AddEquipmentRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                if(key.equals("equipment_id") == false){
                    AddEquipmentRecord = AddEquipmentRecord + "'" + NewEquipmentDataInput.get(key) + "',";
                }
            }
            AddEquipmentRecord = AddEquipmentRecord.substring(0, AddEquipmentRecord.length() - 1) + ")";
            PreparedStatement AddEquipmentRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddEquipmentRecord);
            test = AddEquipmentRecordStatement.executeUpdate();
            EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(EquipmentDataTable.next()){
                    UpdateStatement = "UPDATE equipment_data SET";
                    MakeChange = false;
                    RowID = EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"));
                    for(String key : UserAccountInfo.EquipmentDataColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.EquipmentDataColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.EquipmentDataColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE equipment_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                EquipmentDataTable = UserAccountInfo.getEquipmentDataTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Equipment Data</title>
    </head>
    <body>
        <h1>Equipment Data</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="EquipmentDataGetter" action="EquipmentData.jsp" method="POST">
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
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("equipment_id")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("brand")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("year")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("model")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("type")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("parts_list")%></th>
                        <th><%=UserAccountInfo.EquipmentDataColumnsText.get("maintenance_record_id")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(EquipmentDataTable.next()){%>
                                <tr>
                                    <td><%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("brand"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("brand")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("brand"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("year"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("year")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("year"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("model"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("model")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("model"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("type"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("type")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("type"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("parts_list"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("parts_list")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("parts_list"))%>"/></td>
                                    <td><input style="width: <%=UserAccountInfo.MDEquipmentDataTable.getPrecision(UserAccountInfo.EquipmentDataColumns.get("maintenance_record_id"))*PixelMultiplier%>px;" type="text" name="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("equipment_id"))%> <%=UserAccountInfo.MDEquipmentDataTable.getColumnName(UserAccountInfo.EquipmentDataColumns.get("maintenance_record_id")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=EquipmentDataTable.getString(UserAccountInfo.EquipmentDataColumns.get("maintenance_record_id"))%>"/></td>
                                </tr>
                            
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="EquipmentData.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= EquipmentDataTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDEquipmentDataTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.EquipmentDataColumnsText.get(UserAccountInfo.MDEquipmentDataTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="EquipmentData.jsp" method="POST">
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
        var txt = "Refreshing Equipment Data Page";
        if (document.getElementsByName("RefreshUpdate")[0].value === "Update"){
            txt = "Updating database.  This will take a few moments."
        }
        alert(txt);
    }   
</script>
