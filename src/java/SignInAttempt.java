/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.'
 * Josh Koopman
 */
//package com.journaldev.java.ssh;

import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Connection;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.security.SecureRandom;
import java.sql.ResultSetMetaData;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Owner
 */
public class SignInAttempt extends HttpServlet {

     public class ValidateUser{
            
            String URL_CS499TruckingCompany = "jdbc:mysql://aa1wk12raqf2yoe.ca2f0nfwjqou.us-east-1.rds.amazonaws.com:3306/CS499TruckingCompany";
            String USERNAME = "SeniorProject";
            String PASSWORD = "password";
            String InputUserName = null;
            String InputPassword = null;
            String SQLStatement = null;
            
            Connection CS499Connection = null;
            
            PreparedStatement CheckUserCookiesData = null;
            PreparedStatement CheckUserSignInData = null;
            PreparedStatement UpdateCookie = null;
            PreparedStatement AddCookie = null;
            
            ResultSet UserSignInData = null;
            ResultSet UserCookieData = null;
            
            ResultSetMetaData UserSignInMetaData = null;
            
            Map<String, Integer> UserSignInColumns = new HashMap<String, Integer>();
            
            public ValidateUser() throws ClassNotFoundException, InstantiationException, IllegalAccessException {            
                try{
                    //This line is required to successfully connect to MySQL
                    Class.forName("com.mysql.jdbc.Driver").newInstance();

                    //connection to SQL database establised and statement prepared
                    CS499Connection = DriverManager.getConnection(URL_CS499TruckingCompany, USERNAME, PASSWORD);
                    CheckUserSignInData = CS499Connection.prepareStatement("SELECT * FROM sign_in_data");
                    CheckUserCookiesData = CS499Connection.prepareStatement("SELECT * FROM user_cookies_data");
                    UserSignInData = CheckUserSignInData.executeQuery();
                    UserSignInMetaData = UserSignInData.getMetaData();
                    for(int MetaIndex = 1; MetaIndex <= UserSignInMetaData.getColumnCount(); MetaIndex++){
                        UserSignInColumns.put(UserSignInMetaData.getColumnName(MetaIndex), MetaIndex);
                    }
                    
                }catch(SQLException ex){
                    ex.printStackTrace();
                }  
            }
            
            public int AddUpdateCookie(String UserID, String UserName, String CookieName, 
                    String CookieValue, String IP, String AccessCode){                
                int result = 0; 
                boolean CookieIPFound = false;
                ResultSet CookiesTable = this.getCookies();     
                try{                
                    while(CookiesTable.next()){
                        if(CookiesTable.getString(1).equals(UserID)){
                            CookieIPFound = true;
                            UpdateCookie = CS499Connection.prepareStatement("UPDATE CS499TruckingCompany.user_cookies_data "
                                + "SET "
                                + "user_name = '"+UserName+"', "       
                                + "cookie_name = '"+CookieName+"', "
                                + "cookie_value = '"+CookieValue+"', "
                                + "cookie_ip = '"+IP+"', "
                                + "access_code = '"+AccessCode+"' "
                                + "WHERE "
                                + "cookie_id = '"+UserID+"'");
                            result = UpdateCookie.executeUpdate();
                            break;
                        }
                    }
                    if(CookieIPFound ==  false){
                        AddCookie = CS499Connection.prepareStatement(
                                "INSERT INTO CS499TruckingCompany.user_cookies_data ("
                            + "cookie_id, "
                            + "user_name, "
                            + "cookie_name, "             //sign_in_history Column2
                            + "cookie_value, "         //sign_in_history Column3
                            + "cookie_ip, "        
                            + "access_code) "         //sign_in_history Column4
                            + "VALUES "                 
                            + "('"+UserID+"', "
                            + "'"+UserName+"', "       //RecordSignIn Parameter1   
                            + "'"+CookieName+"', "    //RecordSignIn Parameter2
                            + "'"+CookieValue+"', "
                            + "'"+IP+"', "
                            + "'"+AccessCode+"')");       //RecordSignIn Parameter3
                        result = AddCookie.executeUpdate();
                    }                
                }catch(SQLException ex){
                    ex.printStackTrace();
                }
                return result;
            }
    
            
            public void setUserName(String UserName){
                this.InputUserName = UserName;
            }
            
            public void setPassword(String Password){
                this.InputPassword = Password;
            }
            
            public ResultSet getSignInData(){
                try{
                    UserSignInData = CheckUserSignInData.executeQuery();
                }catch(SQLException ex){
                    ex.printStackTrace();
                }
                return UserSignInData;                    
            }

            public ResultSet getCookies(){
                try{
                    UserCookieData = CheckUserCookiesData.executeQuery();
                }catch(SQLException ex){
                    ex.printStackTrace();
                }
                return UserCookieData;                    
            }
            
            public String getUserName(){
                return this.InputUserName;
            }
            
            public String getPassword(){
                return this.InputPassword;
            }
        }
    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException, InstantiationException, IllegalAccessException {
        boolean SignedIn = false;
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        ValidateUser Validate = new ValidateUser();
        Validate.setUserName(request.getParameter("username"));
        Validate.setPassword(request.getParameter("password"));
        try{
            while(Validate.UserSignInData.next()){
                if(Validate.getUserName().equals(Validate.UserSignInData.getString(Validate.UserSignInColumns.get("user_name"))) &&
                        Validate.getPassword().equals(Validate.UserSignInData.getString(Validate.UserSignInColumns.get("password"))))
                {
                    String CookieName = new BigInteger(130, new SecureRandom()).toString(32);
                    String CookieValue = new BigInteger(130, new SecureRandom()).toString(32);
                    String CookieIP = request.getRemoteAddr().toString();
                    Cookie SignedInCookie = new Cookie(CookieName, CookieValue);
                    response.addCookie(SignedInCookie);  
                    Validate.AddUpdateCookie(
                            Validate.UserSignInData.getString(Validate.UserSignInColumns.get("user_id")), 
                            Validate.UserSignInData.getString(Validate.UserSignInColumns.get("user_name")), 
                            CookieName, 
                            CookieValue, 
                            CookieIP, 
                            Validate.UserSignInData.getString(Validate.UserSignInColumns.get("access_code")));
                    //out.write(Validate.SQLStatement);
                    SignedIn = true;
                    response.sendRedirect("UserSignedIn.jsp");
                }
            }
            if(SignedIn == false){
                response.sendRedirect("index.jsp");
            }
        }catch(SQLException ex){
            ex.printStackTrace();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InstantiationException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IllegalAccessException ex) {
            Logger.getLogger(SignInAttempt.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
