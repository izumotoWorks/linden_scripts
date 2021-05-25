//***************************************************************
//Shared Media上にhttp-inから配信したHTMLを表示させるサンプル
//***************************************************************
//リクエストIDを保持する変数
key url_request;

//HTMLのコード
string HTML_BODY =
"<!DOCTYPE html>
<html>
<body>
<h1>My First Heading</h1>
<p>My first paragraph.</p>
</body>
</html>";

default
{
    state_entry()
    {
        //メディアをクリア(省略可)
        llClearLinkMedia(LINK_THIS,4);
        //http-inのサーバーURLをリクエスト
        url_request = llRequestURL();
    }

    //装着したらリセット
    attach(key attached)
    {
        llResetScript();
    }
 
    http_request(key id, string method, string body)
    {
        if (url_request == id)
        {
            url_request = "";
            //サーバーURLが発行したらメディアを貼り付けてURLを設定する
            if (method == URL_REQUEST_GRANTED){
                integer status = llSetLinkMedia(LINK_THIS, 4, [
                PRIM_MEDIA_HOME_URL, body,
                PRIM_MEDIA_CURRENT_URL, body,
                PRIM_MEDIA_AUTO_ZOOM, TRUE,
                PRIM_MEDIA_AUTO_PLAY, TRUE,
                PRIM_MEDIA_AUTO_SCALE, FALSE,
                PRIM_MEDIA_WIDTH_PIXELS, 1024,
                PRIM_MEDIA_HEIGHT_PIXELS, 1024,
                PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_NONE,
                PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE
                ]);
            }
            //エラー処理 (省略可)
            else if (method == URL_REQUEST_DENIED){
                llOwnerSay("Something went wrong, no url:\n" + body);
            }
       }
       else{
           if(method == "GET" || method == "HEAD"){
               //HTTP headerのContent-TypeをHTMLに設定してResponseする
               llSetContentType(id, CONTENT_TYPE_HTML);
               llHTTPResponse(id, 200, HTML_BODY);
           }
        }
    }
}