using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Prototype
{
    public class Lobby
    {
        public dynamic GameState { get; set; }
        public string GameType { get; set; }
        public List<string> Players { get; set; }

        public Lobby(dynamic gameState, string gameType, List<string> players)
        {
            GameState = gameState;
            GameType = gameType;
            Players = players;
        }

        public Lobby(Lobby other)
        {
            GameState = other.GameState;
            GameType = other.GameType;
            Players = other.Players;
        }
    }
}