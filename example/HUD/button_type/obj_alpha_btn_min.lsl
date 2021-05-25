// ----------------------------------------------------------------------------
// 定数定義　
// ----------------------------------------------------------------------------
float HOLIZONTAL_MIN = -0.71; // 水平位置最小
float HOLIZONTAL_MAX = -0.25; // 水平位置最大
// float hol_diff_ONE_PAR = hol_diff * 0.01; // 差分の1%

// 送信するチャンネル
integer SEND_CHANNEL  = -114514; // 値を変更する際はレシーバー側も変更する必要あり

// メイン関数
default
{
    // タッチされ終わったら動く関数
    touch_end(integer total_number)
    {
        llWhisper( SEND_CHANNEL, "0.0");
    }
}
