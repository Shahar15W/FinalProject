using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Prototype
{
    public partial class Admin : System.Web.UI.Page
    {
        //define variables
        DataTable dt; //datatable
        public string data; //collapsable data form
        private string[] fields = { "fldUsername", "fldPassword", "fldFirstname", "fldCity", "fldPhone", "fldEmail", "fldYear", "fldGender", "fldAccessKey" }; //list of fields in datatable
        private string[] ids = { "uname", "password", "fname", "city", "phone", "email", "year", "gender", "AK" };
        private int countrow; //current row
        private string check;
        private string itemname;
        private bool update;
        private bool logout;
        private string notice;
        protected void Page_Load(object sender, EventArgs e)
        {
            //Test if user can access page
            TestAccess();

            //Get a datatable of all users
            GetDataTableFromDataBase();

            //Build the datatable into a list of form collapsables
            BuildData();

            //Check if data was submitted and confirmed
            if (Request.Form["submit"] != null && Request.Form["confirm_value"] == "yes")
            {
                //Check and update the new data
                Detect();
            }
        }

        //Test if user can access page
        private void TestAccess()
        {
            if (Session["AccessKey"] == null || (int)Session["AccessKey"] < 1)
                Response.Redirect("Home.aspx");
        }

        //Get a datatable of all users ordered by username
        private void GetDataTableFromDataBase()
        {
            string db_name = "SiteData.mdf";
            string sqlQuery = "SELECT *, ROW_NUMBER() OVER(ORDER BY fldUsername) AS Row FROM tblusers";
            dt = ValeryAdoHelper.ExecuteDataTable(db_name, sqlQuery);
        }

        //Build the datatable into a list of form collapsables
        private void BuildData()
        {
            //define variables
            data = "";
            countrow = -1;
            {
                data += "<div id=\"hidden\" style=\"display: none; \">" +
                    "<input id = \"checkADM\" value = \"";
                if ((int)Session["AccessKey"] < 3)
                    data += "0";
                else
                    data += "1";
                data += "\">" +
                "</div>";
            }
            //iterate for each row in datatable
            foreach (DataRow row in dt.Rows)
            {
                //set the row number to the current row
                countrow += 1;
                //check if the current user can access the current row
                if ((int)Session["AccessKey"] < 3 && (string)Session["username"] != (string)row.ItemArray[0])
                    continue;
                //add a series of divs to style a collapsable form
                data += "<div class=\"panel panel-default\"><div class=\"panel-heading\"><h4 class=\"panel-title\"><a data-toggle=\"collapse\" data-parent=\"#accordion\" href=\"#collapse"
                + countrow + "\">User number " + countrow + "; Username: " + row.ItemArray[0] + "</a></h4></div><div id = \"collapse"
                + countrow + "\" class=\"panel-collapse collapse\"><div class=\"panel-body\">";
                //iterate for each item in the current row
                for (int current = 0; current < row.ItemArray.Length - 1; current++)
                {
                    //check if the current user can access the accesskey field
                    if ((int)Session["AccessKey"] < 4 && current == 8)
                        continue;
                    //add all the items to forms
                    data += "<div><h2 class=\"shadow\">" + fields[current] + ":</div><input type=\"text\" value=\"" + row.ItemArray[current] + "\" name=\"row" + countrow
                    + "item" + current + "\"";
                    if ((int)Session["AccessKey"] < 4)
                        data += "id = \"" + ids[current] + "\"";
                    else
                        data += "id =\"row" + countrow + "item" + current + "\"";
                    data += "style =\"background-color: #964B00;color: white;\"> ";
                }
                data += "<div><h2 class=\"shadow\">Delete Account:</div><input type=\"checkbox\" value=\"True\" name=\"row" + countrow
                + "item9\" id=\"row" + countrow + "item9\" style=\"background-color: #964B00;color: whitey;\">";
                //close the divs and add a line
                data += "</div></div><br>";
            }

            //New user
            if ((int)Session["AccessKey"] > 3)
            {
                //form for new user
                data += "<div class=\"panel panel-default\"><div class=\"panel-heading\"><h4 class=\"panel-title\"><a data-toggle=\"collapse\"" +
                " data-parent=\"#accordion\" href=\"#create\">Create New User</a></h4></div><div id = \"create\" class=\"panel-collapse collapse\"><div class=\"panel-body\">";

                for (int current = 0; current < fields.Length; current++)
                {
                    //add all the items to forms
                    data += "<div><h2 class=\"shadow\">" + fields[current] + ":</div><input type=\"text\" value=\"0\" name=\"new" + current
                    + "\" id=\"new " + current + "\" style=\"background-color: #003153;color: gray;\">";
                    data += " ";
                }
                //add the create button
                data += "<div><h2 class=\"shadow\">Create Account:</div><input type=\"checkbox\" value=\"True\" name=\"create\" id=\"create\" style=\"background-color: #003153;color: red;\">";
                //close the divs and add a line
                data += "</div></div><br>";
            }

        }

        //Check and update the new data
        private void Detect()
        {
            logout = false;
            //define variables
            countrow = -1;
            notice = "Changed: ";

            //iterate for each row
            foreach (DataRow row in dt.Rows)
            {
                countrow += 1;
                //check if the current user can access the current row
                if ((int)Session["AccessKey"] < 3 && (string)Session["username"] != (string)row.ItemArray[0])
                    continue;
                //set the flag of new information to false
                update = false;
                //start a new sqlQuery
                string sqlQuery = "UPDATE tblUsers SET ";
                //iterate for each item in row
                for (int current = 0; current < row.ItemArray.Length - 1; current++)
                {
                    //check if the current item in the current row isnt null and the row isnt to be deleted
                    check = "row" + countrow + "item" + current;
                    if (Request.Form[check] != null && row.ItemArray[current] != null && Request.Form["row" + countrow + "item9"] == null)
                        //check if the current item in the current row isnt the same as the data in the datatable
                        if (Request.Form[check].ToString() != row.ItemArray[current].ToString() && Request.Form[check].ToString() != "")
                        {
                            //set the field to be changed to the current field
                            itemname = fields[current];
                            //add the item and field to be changed to the sqlquery
                            sqlQuery += itemname + " = '" + Request.Form[check].ToString() + "',";
                            //add the changed item to a written notice
                            notice += "row" + countrow + ", item" + current + ":" + itemname + " -> " + row.ItemArray[current].ToString() + " => " + Request.Form[check].ToString() + "; ";
                            //set the update flag to true
                            update = true;
                        }
                }
                //if the row is to be deleted
                if (Request.Form["row" + countrow + "item9"] != null)
                {
                    //set the sql query to delete
                    sqlQuery = "DELETE From tblUsers ,";
                    //add deleted row to a written notice
                    notice += "row" + countrow + ": Username -> " + row.ItemArray[0] + " deleted; ";
                    //set the update flag to true
                    update = true;
                    //set the log out flag to true
                    logout = true;
                }
                //iterate a row
                //remove a comma from the sqlquery
                sqlQuery = sqlQuery.Remove(sqlQuery.Length - 1);
                //finish the sql query by making it run on the current row only
                sqlQuery += " FROM(SELECT *, ROW_NUMBER() OVER(ORDER BY fldUsername) AS Row FROM tblUsers) AS tblUsers WHERE Row = " + (countrow + 1) + "";
                //check if the update flag is true
                if (update == true)
                {
                    //run the sqlquery
                    UpdateData(sqlQuery);
                    //if the logout flag is true and the user is low level
                    if (logout == true && (int)Session["AccessKey"] < 3)
                    {
                        //logout the user
                        Response.Write("<script>alert('" + notice + "') </script>");
                    Response.Redirect("Logout.aspx");
                    }
                }
            }
            //create new user if button is ticked
            if (Request.Form["create"] != null)
            {
                string sqlQuery = "EXEC CreateUser ";
                for (int current = 0; current < fields.Length; current++)
                {
                    check = "new" + current;
                    //add the item  to be changed to the sqlquery
                    sqlQuery += "@" + fields[current] + " = '" + Request.Form[check].ToString() + "',";
                }
                //add new user to notice
                notice += "Added new user;";
                //remove last comma
                sqlQuery = sqlQuery.Remove(sqlQuery.Length - 1);
                //run sql query
                UpdateData(sqlQuery);
            }

            //rebuild the datatable and update form
            //get the updated datatable
            GetDataTableFromDataBase();
            //build a new list of collapsaple forms
            BuildData();
            //if the written notice was extneded, print it, if not, mention nothing was changed
            if (notice.Length > 10)
            {
                Response.Write("<script>alert('" + notice + "') </script>");
            }
            else
                Response.Write("<script>alert(' Changed: Nothing ') </script>");
        }

        //Run the update data sql query
        private void UpdateData(string sqlQuery)
        {
            string db_name = "SiteData.mdf";

            //run the query
            ValeryAdoHelper.DoQuery(db_name, sqlQuery);
        }
    }
}