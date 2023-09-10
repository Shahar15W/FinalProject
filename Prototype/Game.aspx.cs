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
using System.Xml.Linq;


namespace Prototype
{
    public partial class Game : System.Web.UI.Page
    {
        protected string data = "";
        protected dynamic json = null;
        protected string path = (string)System.AppDomain.CurrentDomain.BaseDirectory.Split(new[] { "bin" }, StringSplitOptions.None)[0] + "Creations";
        protected string[] dirs = null;
        protected string create = null;
        protected List<Tuple<string, string, dynamic>> lobbies = new List<Tuple<string, string, dynamic>>();
        protected void Page_Load(object sender, EventArgs e)
        {
            dirs = Directory.GetDirectories(path).Select(x => x.Split('\\')[x.Split('\\').Length - 1]).ToArray();

            create += "<div class=\"clearfix\">" + "<label for=\"Lobby\">Enter lobby name: </label>" +
                "<input type=\"text\" placeholder=\"Lobby Name\" name=\"Lobby\" id=\"Lobby\" required\"><br>";

            create += "<label for=\"Creations\">Choose a game: </label>" +
            "<select name=\"Creations\" id=\"Creations\">\n";

            foreach (string dir in dirs)
            {
                create += "<option value=" + dir + "> " + dir + " </option>\n";
            }
            create += "</select><br>";

            create += "<button type=\"submit\" name=\"create\" value=\"create\" class=\"signupbtn\">Create Lobby</button> <br></div>";


            if (Request.Form["submit"] != null)
            {
                Response.Redirect("Main.aspx?game=" + (string)Request.Form["submit"]);
            }
            else if (Request.Form["create"] != null)
            {
                Lobby((string)Request.Form["Lobby"], (string)Request.Form["Creations"]);
            }
            else
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

        public async void Lobby(string LobbyId, string GameType)
        {
            var connection = new HubConnection("http://localhost:8081/Hubs");
            var lobbyHub = connection.CreateHubProxy("LobbyHub");

            connection.Start().Wait();

            await lobbyHub.Invoke("CreateLobby", LobbyId, GameType);

            connection.Dispose();

            Response.Redirect("Main.aspx?game=" + (string)Request.Form["Lobby"]);

            return;
        }
    }
}