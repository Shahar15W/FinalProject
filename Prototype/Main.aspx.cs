using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;


namespace Prototype
{
    public partial class Main : System.Web.UI.Page
    {
        protected string json;
        protected string game;
        protected void Page_Load(object sender, EventArgs e)
        {
            game = Request.QueryString["game"];
            json = LoadJson();
        }
        public string LoadJson()
        {
            return File.ReadAllText(Server.MapPath("~/Creations/" + game + "/data.json"));
        }
    }
}