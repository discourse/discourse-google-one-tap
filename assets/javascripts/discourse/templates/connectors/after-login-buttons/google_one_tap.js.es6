export default{
    actions: {
        didInsertElement(){
            google.accounts.id.renderButton(document.getElementById("google_one_tap"),{theme: "outline", size: "large" });
        }
    }

}
