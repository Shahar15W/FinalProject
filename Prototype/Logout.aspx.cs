using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Prototype
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Abandon();
            Application.Lock();
            Application["usercount"] = (int)Application["usercount"] - 1;
            Application.UnLock();
            Response.Redirect("Home.aspx");
        }
    }
}