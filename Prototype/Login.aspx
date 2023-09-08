<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Prototype.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div style="width:100%; display:inline-block;">
        <form class="form-container" id="form2" runat="server">
            <div class="container">
                <h1>כניסה</h1>
                <p>בבקשה מלא את טופס זה כדי להכנס.</p>
                <hr>
                <label for="email"><b>כתובת אימייל</b></label>
                <input type="text" placeholder="הכנס כתובת אימייל" name="email" id="email" required">

                <label for="psw"><b>סיסמה</b></label>
                <input type="password" placeholder="הכנס סיסמה" id ="psw" name="psw" required>
                <label>
                    <input type="checkbox" checked="checked" name="remember" style="margin-bottom:15px"> זכור אותי
                </label>

                <div class="clearfix">
                    <button type="submit" name="submit" value="Submit" class="signupbtn">כניסה</button>
                </div>
            </div>
        </form>
    </div>
</asp:Content>
