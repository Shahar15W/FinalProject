using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace Prototype
{
    public partial class Game : System.Web.UI.Page
    {
        protected string data = "";
        protected void Page_Load(object sender, EventArgs e)
        {

            string path = Server.MapPath("~/Creations"); //Assuming Test is your Folder
            string json;
            foreach (string folder in Directory.GetDirectories(path))
            {
                json = File.ReadAllText(folder + "/data.json");
                dynamic info = JsonConvert.DeserializeObject(json);

                data += "<div class=\"clearfix\">";
                data += "<button type=\"Submit\" name=\"submit\" id=\""+ Path.GetFileName(folder) + "\" value=\"" + Path.GetFileName(folder) + "\" class=\"signupbtn\" onclick=\"submitit()\">Game: " + info.Gamename + "<br>Created by: " + info.Creator + "<br>Create date: " + info.Date + "</button>";
                data += "</div><br>";
            }

            if(Request.Form["submit"] != null)
            {
                Response.Redirect("Main.aspx?game=" + (string)Request.Form["submit"]);
            }
        }
        public class Persons
        {
            public string FirstName { get; set; }
            public string LastName { get; set; }
        }
    }
}