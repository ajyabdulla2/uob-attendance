import java.io.FileInputStream;
import java.io.IOException;
import java.security.Key;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.PrivateKey;
import java.security.UnrecoverableKeyException;
import java.security.cert.X509Certificate;
import java.util.Collections;
import java.util.HexFormat;

/**
 * Opens the upload keystore the way the Android Gradle plugin does when it
 * signs the APK (load with the store password, then getKey with the key
 * password), so a wrong password or alias is caught before a release build.
 * keytool cannot do this: it ignores -keypass for PKCS12 keystores.
 *
 * Usage: java tool/CheckKeystore.java <keystore-file>
 * Reads ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD
 * from the environment and prints one JSON line (no secrets).
 */
public class CheckKeystore {
  public static void main(String[] args) throws Exception {
    String storePassword = env("ANDROID_KEYSTORE_PASSWORD");
    String alias = env("ANDROID_KEY_ALIAS");
    String keyPassword = env("ANDROID_KEY_PASSWORD");

    KeyStore store = KeyStore.getInstance(KeyStore.getDefaultType());
    try (FileInputStream in = new FileInputStream(args[0])) {
      store.load(in, storePassword.toCharArray());
    } catch (IOException e) {
      boolean wrongPassword = e.getCause() instanceof UnrecoverableKeyException
          || String.valueOf(e.getMessage()).contains("password");
      fail(wrongPassword ? "store_password" : "format", "");
      return;
    }

    if (!store.containsAlias(alias)) {
      fail("alias", String.join(",", Collections.list(store.aliases())));
      return;
    }

    Key key;
    try {
      key = store.getKey(alias, keyPassword.toCharArray());
    } catch (UnrecoverableKeyException e) {
      fail("key_password", "");
      return;
    }
    if (!(key instanceof PrivateKey)) {
      fail("not_private_key", "");
      return;
    }

    X509Certificate cert = (X509Certificate) store.getCertificate(alias);
    byte[] digest = MessageDigest.getInstance("SHA-256").digest(cert.getEncoded());
    String sha256 = HexFormat.ofDelimiter(":").withUpperCase().formatHex(digest);
    System.out.println("{\"ok\":true,\"sha256\":\"" + sha256
        + "\",\"notAfter\":\"" + cert.getNotAfter().toInstant() + "\"}");
  }

  private static String env(String name) {
    String value = System.getenv(name);
    return value == null ? "" : value;
  }

  private static void fail(String error, String aliases) {
    System.out.println("{\"ok\":false,\"error\":\"" + error
        + "\",\"aliases\":\"" + aliases.replace("\"", "") + "\"}");
  }
}
