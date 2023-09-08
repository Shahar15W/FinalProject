using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Prototype
{
    public partial class Login : System.Web.UI.Page
    {
        DataTable dt;
        private string email;
        private string password;
        public string message = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Form["submit"] != null)
            {
                GetDataFromUser();
                GetDataTableFromDataBase();
                //if no datatables were found, send an error
                if (dt.Rows.Count == 0)
                {
                    Response.Write("<script>alert(' Invalid Email or Password ') </script>");
                }
                else
                {
                    //get name, username, and accesskey from datatable and put them in session
                    DataRow row = dt.Rows[0];
                    Object name = row.ItemArray[2].ToString();
                    Object username = row.ItemArray[0].ToString();
                    Object accesskey = dt.Rows[0]["fldAccessKey"];
                    Session["fname"] = name;
                    Session["username"] = username;
                    Session["AccessKey"] = accesskey;
                    //update usercount
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
        //get email and password
        private void GetDataFromUser()
        {
            email = Request.Form["email"];
            password = Request.Form["psw"];
        }
        //get datatable when email and password exist
        private void GetDataTableFromDataBase()
        {
            string db_name = "SiteData.mdf";
            string sqlQuery = "SELECT * FROM tblusers WHERE fldEmail = '" + email + " ' AND fldPassword='" + password + "'";
            dt = ValeryAdoHelper.ExecuteDataTable(db_name, sqlQuery);
        }

    }
}