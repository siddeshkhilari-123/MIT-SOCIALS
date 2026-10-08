package com.mitsocials.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Arrays;

public class PasswordUtil {

    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 65536;
    private static final int KEY_LENGTH = 256;
    private static final int SALT_LENGTH = 16; // 128 bits

    /**
     * Hashes a password using PBKDF2WithHmacSHA256 and a random salt.
     * @param password Raw password string
     * @return Formatted string "salt_hex:hash_hex"
     */
    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }

        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);

        byte[] hash = generateHash(password.toCharArray(), salt);

        return bytesToHex(salt) + ":" + bytesToHex(hash);
    }

    /**
     * Verifies a plain text password against a stored "salt_hex:hash_hex" string.
     * @param password Input password string
     * @param storedHash Formatted stored hash "salt_hex:hash_hex"
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String password, String storedHash) {
        if (password == null || storedHash == null || !storedHash.contains(":")) {
            return false;
        }

        String[] parts = storedHash.split(":");
        if (parts.length != 2) {
            return false;
        }

        byte[] salt = hexToBytes(parts[0]);
        byte[] expectedHash = hexToBytes(parts[1]);

        byte[] actualHash = generateHash(password.toCharArray(), salt);

        return constantTimeEquals(expectedHash, actualHash);
    }

    private static byte[] generateHash(char[] password, byte[] salt) {
        PBEKeySpec spec = new PBEKeySpec(password, salt, ITERATIONS, KEY_LENGTH);
        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance(ALGORITHM);
            return factory.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error hashing password with algorithm: " + ALGORITHM, e);
        } finally {
            spec.clearPassword();
        }
    }

    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a.length != b.length) {
            return false;
        }
        int result = 0;
        for (int i = 0; i < a.length; i++) {
            result |= a[i] ^ b[i];
        }
        return result == 0;
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }

    private static byte[] hexToBytes(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                    + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }
}
