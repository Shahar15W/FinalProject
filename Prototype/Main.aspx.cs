using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using Microsoft.AspNet.SignalR.Client;
using Newtonsoft.Json;
using Microsoft.AspNet.SignalR.Infrastructure;
using System.Threading.Tasks;

namespace Prototype
{
    public partial class Main : System.Web.UI.Page
    {
        protected dynamic json;
        protected string state;
        protected string lobby;
        protected string game = "";
        protected string type;
        protected Dictionary<string, Tuple<double, double, double, double, double, double>> pos;
        protected Dictionary<string, Tuple<double, double, double, double, double, double>> dics;
        protected Dictionary<string, Tuple<double, double, double>> cursors;
        protected Dictionary<string, Tuple<double, double, double>> cursorsdict;
        protected string username = null;

        protected void Page_Load(object sender, EventArgs e)
        {

            Random rnd = new Random();
            username = (string)Session["username"] ?? "Guest-" + rnd.Next();
            

            lobby = Request.QueryString["game"];


            // Create a connection to the SignalR server

            var connection = new HubConnection("http://localhost:8081/Hubs");
            var lobbyHub = connection.CreateHubProxy("LobbyHub");

            connection.Start().Wait();

            lobbyHub.On<string>("GameState", result =>
            {
                // 'lobbies' is the list of lobbies received from the server
                // Handle the list of players as needed
                state = result;

            });

            lobbyHub.On<string>("GameType", result =>
            {
                // 'lobbies' is the list of lobbies received from the server
                // Handle the list of players as needed
                type = result;

            });

            lobbyHub.On<Dictionary<string, Tuple<double, double, double, double, double, double>>>("PlayersPos", result =>
            {
                // 'lobbies' is the list of lobbies received from the server
                // Handle the list of players as needed
                dics = result;

            });

            lobbyHub.On<Dictionary<string, Tuple<double, double, double>>>("CursorsPos", result =>
            {
                // 'lobbies' is the list of lobbies received from the server
                // Handle the list of players as needed
                cursorsdict = result;

            });


            Methods(lobby, lobbyHub, connection);


        }
        public async Task LoadJson(string lobby, IHubProxy lobbyHub)
        {
            await lobbyHub.Invoke("GetGameState", lobby);

            json = JsonConvert.DeserializeObject(state);

            return;
        }

        public async Task GetType(string lobby, IHubProxy lobbyHub)
        {


            await lobbyHub.Invoke("GetGameType", lobby);

            game = type;

            return;
        }
        public async Task GetPlayerPos(string lobby, IHubProxy lobbyHub)
        {


            await lobbyHub.Invoke("GetPlayersPos", lobby);

            pos = dics;

            return;
        }

        public async Task GetCursors(string lobby, IHubProxy lobbyHub)
        {

            await lobbyHub.Invoke("GetCursors", lobby);

            cursors = cursorsdict;

            return;
        }
        public async void Methods(string lobby, IHubProxy lobbyHub, HubConnection connection)
        {
            await LoadJson(lobby, lobbyHub);

            await GetType(lobby, lobbyHub);

            await GetPlayerPos(lobby, lobbyHub);

            await GetCursors(lobby, lobbyHub);

            connection.Dispose();

            return;
        }
    }
}