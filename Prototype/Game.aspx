<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="Game.aspx.cs" Inherits="Prototype.Game" Async="true" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div style="padding:20px;margin-top:30px;height:100%;">
    <form class="form-container" method="post" id="form2" runat="server" >

        <%=data %>
    </form>
</div>
</asp:Content>
