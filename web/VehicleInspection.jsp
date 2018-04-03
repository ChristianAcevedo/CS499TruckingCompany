<%-- 
    Document   : VehicleInspection
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
    public class VehicleInspection{

        String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
        String USERNAME = "SeniorProject";
        String PASSWORD = "password";
        String AccessCode = "";

        Connection TruckingConnection = null;

        PreparedStatement GetCookiesTable = null;
        PreparedStatement GetSignInDataTable = null;
        PreparedStatement GetVehicleInspectionTable = null;

        ResultSet RSCookiesTable = null;
        ResultSet RSSignInDataTable = null;
        ResultSet RSVehicleInspectionTable = null;

        ResultSetMetaData MDCookiesTable = null;
        ResultSetMetaData MDSignInDataTable = null;
        ResultSetMetaData MDVehicleInspectionTable = null;

        Map<String, Integer> UserCookiesColumns = new HashMap<String, Integer>();
        Map<String, Integer> SignInDataColumns = new HashMap<String, Integer>();
        Map<String, Integer> VehicleInspectionColumns = new HashMap<String, Integer>();
        Map<String, Integer> VehicleInspectionColumnsPrecision = new HashMap<String, Integer>();

        Map<String, String> VehicleInspectionColumnsText = new HashMap<String, String>();

        VehicleInspection(String input_param){
        
            try{
                TruckingConnection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                GetCookiesTable = TruckingConnection.prepareStatement("SELECT * FROM user_cookies_data");
                GetSignInDataTable = TruckingConnection.prepareStatement("SELECT * FROM sign_in_data");
                GetVehicleInspectionTable = TruckingConnection.prepareStatement("SELECT * FROM vehicle_inspections WHERE vehicle_id=" + input_param + "");
                RSCookiesTable = GetCookiesTable.executeQuery();
                RSSignInDataTable = GetSignInDataTable.executeQuery();
                RSVehicleInspectionTable = GetVehicleInspectionTable.executeQuery();
                MDCookiesTable = RSCookiesTable.getMetaData();
                MDSignInDataTable = RSSignInDataTable.getMetaData();
                MDVehicleInspectionTable = RSVehicleInspectionTable.getMetaData();
                for(int MetaIndex = 1; MetaIndex <= MDCookiesTable.getColumnCount(); MetaIndex++){
                    UserCookiesColumns.put(MDCookiesTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDSignInDataTable.getColumnCount(); MetaIndex++){
                    SignInDataColumns.put(MDSignInDataTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDVehicleInspectionTable.getColumnCount(); MetaIndex++){
                    VehicleInspectionColumns.put(MDVehicleInspectionTable.getColumnName(MetaIndex), MetaIndex);
                }
                for(int MetaIndex = 1; MetaIndex <= MDVehicleInspectionTable.getColumnCount(); MetaIndex++){
                    VehicleInspectionColumns.put(MDVehicleInspectionTable.getColumnName(MetaIndex), MetaIndex);
                    VehicleInspectionColumnsPrecision.put(MDVehicleInspectionTable.getColumnName(MetaIndex), MDVehicleInspectionTable.getPrecision(MetaIndex));
                    VehicleInspectionColumnsText.put(MDVehicleInspectionTable.getColumnName(MetaIndex), 
                        MDVehicleInspectionTable.getColumnName(MetaIndex).toUpperCase().replaceAll("_", " "));
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

        public ResultSet getVehicleInspectionTable(){
            try{
                RSVehicleInspectionTable = GetVehicleInspectionTable.executeQuery();
            }catch(SQLException ex){
                ex.printStackTrace();
            }
            return RSVehicleInspectionTable;   
        }
}
%>

<%
    
    String vehicle_id_param = request.getParameter("vehicle_id_param");
    
    boolean SignedIn = false;    
        String UserName = "";   
        String UserID = "";
        String AccessCode = "";
        VehicleInspection UserAccountInfo = new VehicleInspection(vehicle_id_param);
        Map<String, String> NewVehicleInspectionInput = new HashMap<String, String>();
        
        
        ResultSet CookiesTable = UserAccountInfo.getCookiesTable(); 
        ResultSet SignInDataTable = UserAccountInfo.getSignInDataTable();
        ResultSet VehicleInspectionTable = UserAccountInfo.getVehicleInspectionTable();
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
        for (String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()) {
            if(request.getParameter(UserAccountInfo.VehicleInspectionColumnsText.get(key) + " INPUT") == null ||
                    request.getParameter(UserAccountInfo.VehicleInspectionColumnsText.get(key) + " INPUT") == ""){
                if(key.equals("inspection_id") == false){
                    GoodInput = false;
                    break;
                }                
            }else{
                //if(key.equals())
                NewVehicleInspectionInput.put(key,request.getParameter(UserAccountInfo.VehicleInspectionColumnsText.get(key) + " INPUT"));
            }
        }
        
        int test = 0;
        String AddVehicleInspectionRecord = "INSERT INTO vehicle_inspections (";
        if(GoodInput == true){
            for(String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()){
                if(key.equals("inspection_id") == false) {
                    AddVehicleInspectionRecord = AddVehicleInspectionRecord + key + ",";
                }
            }
            
            AddVehicleInspectionRecord = AddVehicleInspectionRecord.substring(0, AddVehicleInspectionRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()){
                if((key.equals("inspection_id") == false) && (key.equals("vehicle_id") == false)){
                    AddVehicleInspectionRecord = AddVehicleInspectionRecord + "'" + NewVehicleInspectionInput.get(key) + "',";
                }
                if(key.equals("vehicle_id") == true)
                {
                    AddVehicleInspectionRecord = AddVehicleInspectionRecord + "'" + vehicle_id_param + "',";
                }
            }
            
/*
            AddVehicleInspectionRecord = AddVehicleInspectionRecord.substring(0, AddVehicleInspectionRecord.length() - 1) + ") VALUES (";
            for(String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()){
                if(key.equals("inspection_id") == false){
                    AddVehicleInspectionRecord = AddVehicleInspectionRecord + "'" + NewVehicleInspectionInput.get(key) + "',";
                }
            }
*/
            AddVehicleInspectionRecord = AddVehicleInspectionRecord.substring(0, AddVehicleInspectionRecord.length() - 1) + ")";
            PreparedStatement AddVehicleInspectionRecordStatement = 
                    UserAccountInfo.TruckingConnection.prepareStatement(AddVehicleInspectionRecord);
            test = AddVehicleInspectionRecordStatement.executeUpdate();
            VehicleInspectionTable = UserAccountInfo.getVehicleInspectionTable();
        }
        
        if(request.getParameter("RefreshUpdate") != null){
            if(request.getParameter("RefreshUpdate").equals("Update")){
                String RowID = "0";
                String UpdateStatement = "";
                String CurrentParameter = "";
                boolean MakeChange = false;
                while(VehicleInspectionTable.next()){
                    UpdateStatement = "UPDATE vehicle_inspections SET";
                    MakeChange = false;
                    RowID = VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get("inspection_id"));
                    for(String key : UserAccountInfo.VehicleInspectionColumnsText.keySet()){
                        if(request.getParameter(RowID + " " + UserAccountInfo.VehicleInspectionColumnsText.get(key) + " UPDATE") != null){
                            CurrentParameter = request.getParameter(RowID + " " + UserAccountInfo.VehicleInspectionColumnsText.get(key) + " UPDATE");
                            if(CurrentParameter.equals("") == false && 
                                CurrentParameter.equals(VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get(key))) == false){
                                MakeChange = true;
                                UpdateStatement = UpdateStatement + " " + key + "='" + CurrentParameter + "',";
                            }
                        }
                    }
                    if(MakeChange == true){
                        UpdateStatement = UpdateStatement.substring(0, UpdateStatement.length() - 1) + " WHERE inspection_id = '" + RowID + "'";
                        PreparedStatement UpdateDatabase = UserAccountInfo.TruckingConnection.prepareStatement(UpdateStatement);
                        UpdateDatabase.executeUpdate();
                    }
                }
                VehicleInspectionTable = UserAccountInfo.getVehicleInspectionTable();
            }
        }
        String IncomingOutgoingText = "";
        int PixelMultiplier = 8;
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Vehicle Inspection</title>
    </head>
    <body>
        <h1>Vehicle Inspection</h1>
        <form name="GoToMainMenu" action="UserSignedIn.jsp" method="POST">
            <input type="submit" value="Go to Main Menu" name="Main Menu" />
        </form>
        <form name="VehicleInspectionGetter" action="VehicleInspection.jsp" method="POST">
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
                        <th><%=UserAccountInfo.VehicleInspectionColumnsText.get("inspection_id")%></th>
                        <th><%=UserAccountInfo.VehicleInspectionColumnsText.get("vehicle_id")%></th>
                        <th><%=UserAccountInfo.VehicleInspectionColumnsText.get("date")%></th>
                    </tr>
                </thead>
                <tbody>
                    <form
                     <%try{
                        while(VehicleInspectionTable.next()){%>
                                <tr>
                                    <td><%=VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get("inspection_id"))%></td>
                                    <td><%=VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get("vehicle_id"))%></td>
                                    <td><input style="width: <%=UserAccountInfo.MDVehicleInspectionTable.getPrecision(UserAccountInfo.VehicleInspectionColumns.get("date"))*PixelMultiplier%>px;" type="text" name="<%=VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get("inspection_id"))%> <%=UserAccountInfo.MDVehicleInspectionTable.getColumnName(UserAccountInfo.VehicleInspectionColumns.get("date")).toUpperCase().replaceAll("_", " ")%> UPDATE" value="<%=VehicleInspectionTable.getString(UserAccountInfo.VehicleInspectionColumns.get("date"))%>"/></td>
                                </tr> 
                        <%}%>
                    <%}catch(SQLException ex){
                        ex.printStackTrace();
                    }%>   
                    <tr>
                        <form action="VehicleInspection.jsp" method="POST">
                            <td><input type="submit" value="Add Data" name="AddDataBtn" /></td>
                            <%for(int MetaIndex = 2; MetaIndex <= VehicleInspectionTable.getMetaData().getColumnCount(); MetaIndex++){    
                                int size = UserAccountInfo.MDVehicleInspectionTable.getPrecision(MetaIndex) * PixelMultiplier;%>
                            <td><input style="width: <%=size%>px;" type="text" name="<%=UserAccountInfo.VehicleInspectionColumnsText.get(UserAccountInfo.MDVehicleInspectionTable.getColumnName(MetaIndex))%> INPUT" value="" /></td>
                            <input type="hidden" name="vehicle_id_param" value="<%=vehicle_id_param%>">
                            <%}%> 
                        </form>
                    </tr>                 
                </tbody>
            </table>
        </form>   
        <form name="DeleteUpdate" action="VehicleInspection.jsp" method="POST">
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
