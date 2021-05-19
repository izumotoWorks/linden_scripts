//=============================================================================
// HUD de Alpha変更 トランスミッター用スクリプト v0.1.0
// ----------------------------------------------------------------------------
// (C)2021 Enhanced System
// This software is released under the MIT License.
// http://opensource.org/licenses/mit-license.php
// ----------------------------------------------------------------------------
// Version
// 0.1.0 2021/05/19 β版
// ----------------------------------------------------------------------------
// [GitHub] : https://github.com/izumotoWorks/linden_scripts
//=============================================================================

// ----------------------------------------------------------------------------
// 定数定義　
// ----------------------------------------------------------------------------
float C_VISIBLE = 1.000000; // 不透明度
float C_OUTOF_RANGE = -1.000000; // 異常範囲の値
float ALPHA_MAX_RANGE = 0.7; // スライダー調整用
float HOLIZONTAL_MIN = -0.71; // 水平位置最小
float HOLIZONTAL_MAX = -0.25; // 水平位置最大
vector WHITE_COLOR = <1.0,1.0,1.0>; // テキストカラー
// float hol_diff_ONE_PAR = hol_diff * 0.01; // 差分の1%

// 送信するチャンネル
integer SEND_CHANNEL  = -114514; // 値を変更する際はレシーバー側も変更する必要あり


// ----------------------------------------------------------------------------
// 変数定義　
// ----------------------------------------------------------------------------

// 位置保存変数
vector before_pos;
vector touch_pos;

// テクスチャ位置差分値
float hol_diff;

integer listen_handle; // リッスンハンドラ
// ----------------------------------------------------------------------------
// 自作関数群
// ----------------------------------------------------------------------------

// アルファ値のテキスト変更
nl_change_txt() {
    if(before_pos.x == C_OUTOF_RANGE) {
        // 0%を表記
        llSetText("0%", WHITE_COLOR, 1.0);
    } else if(before_pos.x >= C_VISIBLE) {
        // 100%を表記
        llSetText("100%", WHITE_COLOR, 1.0);
    } else {
        // 小数点すべて表示
        llSetText((string)(before_pos.x * 100.0)+"%", WHITE_COLOR, 1.0);
    }

}



// ----------------------------------------------------------------------------
// メイン関数
// ----------------------------------------------------------------------------

default
{
    // アタッチ時に動作する初期化関数
    state_entry() {
        before_pos = <0.0,0.0,0.0>;
        touch_pos = <0.0,0.0,1.0>; // 初期値がbefore_posとかぶらないようにZ軸の値を変更してるだけ
        hol_diff = llFabs(HOLIZONTAL_MIN - HOLIZONTAL_MAX); // 水平値差分
        
        // 指定チャネル + 指定名で　指定UUIDのプリムに対してリッスンする
        listen_handle = llListen(SEND_CHANNEL, "", NULL_KEY, "");
    }
    
    // チャネルに受信したら動作
    listen( integer channel, string name, key id, string message )
    {
        if(message == "1.0") {
            // 不透明にする
            llOffsetTexture(HOLIZONTAL_MAX,0.0, ALL_SIDES);
            before_pos = <1.0,0.0,0.0>;
        } else if(message == "0.0") {
            // 透明にする
            llOffsetTexture(HOLIZONTAL_MIN,0.0, ALL_SIDES);
            before_pos = <0.0,0.0,0.0>;
        }
        // オブジェクトの上に現状の％を更新
        nl_change_txt();
    }
    // タッチされている最中に動く関数
    touch(integer total_number) {
        // タッチされた位置をVectorで取得
        touch_pos = llDetectedTouchST(0);
        // 同じ位置をタッチし続けたときの連続動作防止用
        integer _after = llRound(touch_pos.x * 10);
        integer _before = llRound(before_pos.x * 10);
        // タッチした位置が変わっていれば動作
        if(_before != _after) {

            // 範囲外に行った時に -1.000000 になるので対策
            if(touch_pos.x == C_OUTOF_RANGE) {
                if(before_pos.x > ALPHA_MAX_RANGE) {
                    // ドラッグして範囲外にカーソルが行った時に１つ前の値が0.7より上であればと明度を1.0にする
                    touch_pos.x = C_VISIBLE;
                    // ドラッグして範囲外にカーソルが行った時に１つ前の値が0.7以下であればと明度を0.0にする
                }
            }
            
            // before_posを今回タッチした位置に上書きしておく
            before_pos = touch_pos;
        }
    }

    // タッチされ終わったら動く関数
    touch_end(integer total_number)
    {
        // 水平値を計算 0.0 => -71.0, 1.0 => -0.25になるように
        float hol_now = HOLIZONTAL_MIN + (hol_diff * touch_pos.x);

        // 範囲超え調整
        if(hol_now < HOLIZONTAL_MIN) {
            hol_now = HOLIZONTAL_MIN;
        } else if(hol_now > HOLIZONTAL_MAX) {
            hol_now = HOLIZONTAL_MAX;
        }

        // テクスチャにα値を反映
        llOffsetTexture(hol_now,0.0, ALL_SIDES);
        
        // レシーバーにタッチした値を送信する(同じチャンネルリッスン且つ10m以内の対象に送信)
        llWhisper( SEND_CHANNEL, (string)before_pos.x);
        // オブジェクトの上に現状の％を更新
        nl_change_txt();
    }
}
