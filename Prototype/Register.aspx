<%@ Page Title="" Language="C#" MasterPageFile="~/SiteMaster.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="Prototype.Register" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div style="width:100%; display:inline-block;">
        <form class="form-container" id="form2" runat="server" >
            <div class="container">
                <h1>הרשמה</h1>
                <p>בבקשה מלא טופס זה כדי להרשם.</p>
                <hr>
                <label for="email"><b>כתובת אימייל</b></label>
                <input type="text" id ="email" placeholder="הכנס כתובת אימייל" name="email" required>

                <label for="uname"><b>שם משתמש</b></label>
                <input type="text" id="uname" placeholder="הכנס שם משתמש" name="uname" required>

                <label for="fname"><b>שם פרטי</b></label>
                <input type="text" id="fname" placeholder="הכנס שם פרטי" name="fname" required>

                <label for="phone"><b>מספר טלפון</b></label>
                <input type="text" id="phone" style="direction:ltr;text-align:right" placeholder="הכנס מספר טלפון" name="phone" required>

                <label for="psw"><b>סיסמה</b></label>
                <input type="password" id="password" placeholder="הכנס סיסמה" name="psw" required>

                <label for="psw-repeat"><b>הכנס סיסמה בשנית</b></label>
                <input type="password" id="pswr" placeholder="הכנס סיסמה בשנית" name="psw-repeat" required>
                
                <label for="year"><b>שנת לידה</b></label>
                <input type="text" id="year" placeholder="הכנס שנת לידה" name="year" required>
                

                <p><b>בחר מגדר:</b></p>
                <input type ="radio" checked name ="gender" id="male"  value="False">
                <label for="male">זכר</label>
                <input type ="radio" name ="gender" id="female"  value="True">
                <label for="female">נקבה</label>

                <br />
                <br />


                <label for="City"><b>בחר עיר:</b></label>
                <select name="city" id="city" style="display:block">
                    <option value="Haifa">חיפה</option>
                    <option value="Tel-Aviv">תל אביב</option>
                </select>

                <br />


                <label>
                    <input type="checkbox" checked="checked" name="remember" style="margin-bottom:15px;margin-top:15px"> זכור אותי
                </label>

                <p>בכך שאתה נרשם אתה מסכים  <a target="_blank" rel="noopener noreferrer" href="https://www.youtube.com/watch?v=Tt7bzxurJ1I" style="color:dodgerblue">לתנאים והתניות שלנו</a>.</p>

                <div class="clearfix">

                    <button type="Submit" disabled name="submit" id="submit" value="Submit" class="signupbtn" onclick="submitit()">הרשמה</button>
                    <script src="../JS/Check.js"></script>
                </div>
            </div>
        </form>
    </div>
</asp:Content>
