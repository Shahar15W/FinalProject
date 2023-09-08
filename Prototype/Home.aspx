<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Prototype.Home" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        body{
            -webkit-animation: bgcolor 20s infinite;
            animation: bgcolor 10s infinite;
            -webkit-animation-direction: alternate;
            animation-direction: alternate;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div style="padding:20px;margin-top:30px;height:100%;">
        <h1 class="shadow" style="font-size:100px; text-align: center;">The Toy Box</h1>
    </div>
</asp:Content>
