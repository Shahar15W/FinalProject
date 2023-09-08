<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="Prototype.Admin" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>

        body {
            -webkit-animation: bgcolor 20s infinite;
            animation: bgcolor 10s infinite;
        }
        .panel-group{
            border-radius:1% 1% 1% 1%;
            border-style:dotted dashed;
            border-color:gold orange;
        }
        .clearfix{
            border-radius:1% 1% 1% 1%;
            border-style:dotted dashed;
            border-color:gold orange;
        }
    </style>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>
</asp:Content>  

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div style="margin-right:25%;padding:1px 16px;font-weight:bold;">
        <form class="form-container" id="form2" runat="server">
                <div class="panel-group" id="accordion">
                <%=data %>
                </div>
                <div class="clearfix">
                <button type="Submit" name="submit" id="submit" value="Submit" class="signupbtn" onmouseover="submitit()" onclick="myFunction();submitit()"
                    style="float: right;margin-top:1%;margin-bottom:1%;margin-right:1%;"><h4 style ="color:orangered">שנה נתונים</h4></button>
                    <script src="../JS/Check.js"></script>
                </div>
        </form>
        
        </div>
    <script>
        //close all collapsables when opening one
        jQuery('.collapse').on('show.bs.collapse', function () {
            jQuery('.collapse').removeClass('in');
        });

        //confirm user choice
        function myFunction() {
            let text = "Are you sure you want to make those changes to your account/s?\nPress either OK or Cancel.";
            var confirm_value = document.createElement("INPUT");
            confirm_value.type = "hidden";
            confirm_value.name = "confirm_value";
            if (confirm(text)) {
                text = "You confirmed the changes";
                confirm_value.value = "yes";
            }
            else {
                text = "You canceled the changes";
                confirm_value.value = "no";
            }
            alert(text);
            document.forms[0].appendChild(confirm_value);
        }
    </script>
</asp:Content>

