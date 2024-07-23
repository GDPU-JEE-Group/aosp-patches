package android.net;

import android.util.Log;


    /**
    * @hide
    */
public class Alog  {

    private static  String TAGCX = "chaixiang-Tele";


    /**
    * @hide
    */
    public static void set(String tag) {
        // =====================================
        TAGCX=tag;
    } 

        /**
    * @hide
    */
    public static void logcx(String tag,String s) {
        // =====================================
        Log.d(tag,s);
    } 

            /**
    * @hide
    */
    public static void logcx(String s) {
        // =====================================
        Log.d(TAGCX,s);
    } 

    /**
    * @hide
    */
    public static String MYLOG(String funName, String origin, String replaced) {
        // =====================================
        Log.d(TAGCX, "funName: " + funName);
        Log.d(TAGCX, "origin: " + origin);
        Log.d(TAGCX, "replaced: " + replaced);
        return replaced;
    }

    /**
    * @hide
    */
    public static int MYLOG(String funName,int origin,int replaced) {
        Log.d(TAGCX,"funName: "+funName);
        Log.d(TAGCX,"origin:"+origin);
        Log.d(TAGCX,"replaced:"+replaced);
        return replaced;
    }

    /**
    * @hide
    */
    public static boolean MYLOG(String funName,boolean origin,boolean replaced) {
        Log.d(TAGCX,"funName: "+funName);
        Log.d(TAGCX,"origin:"+origin);
        Log.d(TAGCX,"replaced:"+replaced);
        return replaced;
    }

    /**
    * @hide
    */
    public static void printstack(String fun) {
        if(true)
            return;
            
        // 打印调用栈信息----------------
        String TAGCX="";
        Log.d(TAGCX,"---: 打印调用栈信息");
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        String logg="";
        for (StackTraceElement element : stackTrace) {
            logg+=element.getClassName() + "." + element.getMethodName()+'\n';
            // System.out.println(element.getClassName() + "." + element.getMethodName());
            Log.d(TAGCX,element.getClassName() + "." + element.getMethodName());
        }
        // ----------------------------

        // Log.d(TAGCX,logg);
    } 
}
