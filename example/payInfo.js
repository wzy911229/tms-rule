import {  PayChannel, StripePayChannel, UnifyPayChannel, PayResultCode } from '@terminus/react-native-payments'

export const unifyWechatPay = {
    payments: UnifyPayChannel.WechatPay, 
    appid : 'wxc3f83491b0498799',
    minipath : "pages/appPay/index",
    miniuser : "gh_744d2ebca056",
    noncestr : 'lmQhfPhWQmJyzMBtxvDVHDWpCtrIGMoI',
    package : "Sign=WXPay",
    partnerid : '336872024',
    prepayid : 'c9b5e679162045e992cf5ed9ff3c5874',
    sign : '8E4A181F4FD37E711D9F54A5AD19C047',
    timestamp : '20200827091150',
  }

  export const unifyAliPay = {
    payments: UnifyPayChannel.AliPay, 
    appScheme : "paydemo",
    minipath : "pages/appPay/index/index",
    miniuser : "2019010762862511",
    msgType : "trade.appPreOrder",
    noncestr : "uJoCBwINTLZHrhkBjSFZIYUZhOrGboHV",
    package : "Sign=ALI",
    prepayid : "bf6a25502dc048fcb354a26773acdf2f",
    sign : "E1A99D0DA125FEC082EEC9C85BDB34A0",
    timestamp : "20200915164706"
  }
  
  export const unifyUnionPay = {
    payments: UnifyPayChannel.UnionPay, 
    tn : "760304680402643789213",
  }
  
  