package util;

import javax.servlet.http.Cookie;
import java.security.MessageDigest;
import sun.misc.BASE64Encoder;
import java.security.SecureRandom;
import java.math.BigInteger;

public class Toolbox {
    public static Cookie getCookieByName(Cookie[] cookies, String key) {
        for (Cookie c: cookies)
            if (c.getName().equals(key))
                return c;
        return null;
    }
    
    public static String getHashedUserID(String userID, String userAddress, String secret) {
        MessageDigest md = null;
        try {
            md = MessageDigest.getInstance("SHA1");
            md.update((secret+userID+userAddress+secret).getBytes("UTF-8"));
        } catch (Exception e) { e.printStackTrace(); }
        return (new BASE64Encoder()).encode(md.digest());
    }

    public static String randomString(int length) {
        SecureRandom random = new SecureRandom();
        return new BigInteger(130, random).toString(32).substring(0, length);
    }
}


