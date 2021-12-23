// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// [START gmail_update_signature]
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.GmailScopes;
import com.google.api.services.gmail.model.*;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.File;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.List;

/* Class to demonstrate the use of Gmail Update Signature API */
public class UpdateSignature {
    // Application name.
    private static final String APPLICATION_NAME = "Update Signature Gmail API Sample";
    // Global instance of the JSON factory.
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    // Directory to store authorization tokens for this application.
    private static final String TOKENS_DIRECTORY_PATH = "tokens";

    /**
     * Global instance of the scopes required by this quickstart. If modifying these scopes, delete
     * your previously saved tokens/ folder.
     */
    private static final List<String> SCOPES = Collections.singletonList(GmailScopes.GMAIL_SETTINGS_BASIC);
    private static final String CREDENTIALS_FILE_PATH = "/credentials.json";

    /**
     * Creates an authorized Credential object.
     *
     * @param HTTP_TRANSPORT The network HTTP Transport.
     * @return An authorized Credential object.
     * @throws IOException If the credentials.json file cannot be found.
     */
    private static Credential getCredentials(final NetHttpTransport HTTP_TRANSPORT)
            throws IOException {
        // Load client secrets.
        InputStream in = UpdateSignature.class.getResourceAsStream(CREDENTIALS_FILE_PATH);
        if (in == null) {
            throw new FileNotFoundException("Resource not found: " + CREDENTIALS_FILE_PATH);
        }
        GoogleClientSecrets clientSecrets =
                GoogleClientSecrets.load(JSON_FACTORY, new InputStreamReader(in));

        // Build flow and trigger user authorization request.
        GoogleAuthorizationCodeFlow flow =
                new GoogleAuthorizationCodeFlow.Builder(HTTP_TRANSPORT, JSON_FACTORY, clientSecrets, SCOPES)
                        .setDataStoreFactory(new FileDataStoreFactory(new File(TOKENS_DIRECTORY_PATH)))
                        .setAccessType("offline")
                        .build();
        LocalServerReceiver receiver = new LocalServerReceiver.Builder().setPort(8888).build();
        Credential credential = new AuthorizationCodeInstalledApp(flow, receiver).authorize("user");
        //returns an authorized Credential object.
        return credential;
    }

    public static void main(String... args) throws IOException, GeneralSecurityException {
        //Build a new authorized API client service
        final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
        // Create the gmail API client
        Gmail service = new Gmail.Builder(new NetHttpTransport(), JSON_FACTORY, getCredentials(HTTP_TRANSPORT))
                        .setApplicationName(APPLICATION_NAME)
                        .build();

        try {
            SendAs primaryAlias = null;
            ListSendAsResponse aliases = service.users().settings().sendAs().list("me").execute();
            for (SendAs alias : aliases.getSendAs()) {
                if (alias.getIsPrimary()) {
                    primaryAlias = alias;
                    break;
                }
            }
            SendAs aliasSettings = new SendAs().setSignature("This is my new signature");
            SendAs result = service.users().settings().sendAs().patch(
                            "me",
                            primaryAlias.getSendAsEmail(),
                            aliasSettings)
                    .execute();
            // Prints the updated signature
            System.out.println("Updated signature - " + result.getSignature());
        } catch (GoogleJsonResponseException e) {
            System.err.println("Unable to update signature: " + e.getDetails());
            throw e;
        }
    }
}
// [END gmail_update_signature]