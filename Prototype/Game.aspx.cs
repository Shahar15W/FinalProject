using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.AspNet.SignalR.Client;
using Microsoft.AspNet.SignalR.Infrastructure;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading.Tasks;


namespace Prototype
{
    public partial class Game : System.Web.UI.Page
    {
        protected string data = "";
        protected dynamic json = null;
        protected List<Tuple<string, string, dynamic>> lobbies = new List<Tuple<string, string, dynamic>>();
        protected void Page_Load(object sender, EventArgs e)
        {
            // Create a connection to the SignalR server

            var connection = new HubConnection("http://localhost:8081/Hubs");
            var lobbyHub = connection.CreateHubProxy("LobbyHub");

            lobbyHub.On<List<Tuple<string, string, dynamic>>>("ListOfLobbies", list =>
            {
                // 'lobbies' is the list of lobbies received from the server
                // Handle the list of players as needed
                lobbies = list;
            });





            connection.Start().Wait();
            MakeZibi(lobbyHub, connection);

            

            if(Request.Form["submit"] != null)
            {
                Response.Redirect("Main.aspx?game=" + (string)Request.Form["submit"]);
            }

            
        }
        public async void MakeZibi(IHubProxy lobbyHub, HubConnection connection)
        {

            await lobbyHub.Invoke("GetLobbies");
            foreach (Tuple<string, string, dynamic> lobby in lobbies)
            {

                dynamic state = JsonConvert.DeserializeObject(lobby.Item3);

                data += "<div class=\"clearfix\">";
                data += "<button type=\"Submit\" name=\"submit\" id=\"" + lobby.Item1 + "\" value=\"" + lobby.Item1 + "\" class=\"signupbtn\" onclick=\"submitit()\">Lobby Name: " + lobby.Item1 + "<br>Game: " + lobby.Item2 + "<br>Created by: " + state.Creator + "<br>Create date: " + state.Date + "</button>";
                data += "</div><br>";
            }
            connection.Dispose();
            return;
        }
    }
}