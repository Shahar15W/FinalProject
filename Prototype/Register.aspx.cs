using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Prototype
{
    public partial class Register : System.Web.UI.Page
    {
        private string email;
        private string password;
        private string passwordr;
        private bool gender;
        private int year;
        public string message = "";
        string sqlQuery = "";
        private string username;
        private string firstname;
        private string city;
        private string phone;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Form["submit"] != null)
            {
                GetDataFromUser();
                //check if email already exists
                if (ValeryAdoHelper.IsExist("SiteData.mdf", sqlQuery))
                {
                    Response.Write("<script>alert(' Email Already Used ') </script>");
                }
                //check if passwords dont match
                else if (password != passwordr)
                {
                    Response.Write("<script>alert(' Passwords dont match ') </script>");
                }
                else
                {
                    //create a sql query to add new user and run it
                    sqlQuery = "EXEC CreateUser @fldUsername ='" + username + "',@fldPassword = '" + password + "',@fldFirstname = '" + firstname + "',@fldCity = '"
                    + city + "',@fldPhone = '" + phone + "',@fldEmail = '" + email + "',@fldYear = '" + year + "',@fldGender = '" + (bool)gender + "',@fldAccessKey = '" + 1 + "'";
                    ValeryAdoHelper.DoQuery("SiteData.mdf", sqlQuery);
                    //add name, username, and accesss key to session
                    Session["fname"] = firstname;
                    Session["username"] = username;
                    Session["AccessKey"] = 1;
                    //update user count
                    Application.Lock();
                    if (Application["usercount"] == null)
                        Application["usercount"] = 0;
                    Application["usercount"] = (int)Application["usercount"] + 1;
                    Application.UnLock();
                    //redirect to homepage
                    Session["connecting"] = true;
                    Response.Redirect("Home.aspx");
                }
            }
        }
        //Gets all the datatable fields from user
        private void GetDataFromUser()
        {
            email = Request.Form["email"];
            password = Request.Form["psw"];
            passwordr = Request.Form["psw-repeat"];
            gender = bool.Parse(Request.Form["gender"]);
            username = Request.Form["uname"];
            firstname = Request.Form["fname"];
            city = Request.Form["city"];
            phone = Request.Form["phone"];
            year = int.Parse(Request.Form["year"]);
        }

    }
}