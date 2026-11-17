# Integrate Gitea with Keycloak using OpenID Connect (OIDC)

You need to configure a dedicated Keycloak realm, create a client, and map user groups/roles to Gitea permissions. [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457), [2] (https://www.talkingquickly.co.uk/gitea-sso-with-keycloak-openldap-openid-connect)

1. Keycloak Configuration Steps


## Create a Realm

• In the Keycloak Admin Console, create a new realm (e.g., named gitea or dev). [1] (https://www.youtube.com/watch?v=WGcgiegv0W0), [2] (https://www.youtube.com/watch?v=toEVcosbedw&t=356)

## Create Groups or Roles

• Navigate to Groups and create groups to control Gitea access:
	• gitea-users (Standard user access)
	• gitea-admins (Site Administrator access) [1] (https://www.youtube.com/watch?v=A1WL1jNUwqU&t=82), [2] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)
• Add your test/production users to these groups. [1] (https://www.youtube.com/watch?v=A1WL1jNUwqU&t=82)

## Create a Client Scope for Groups

• Go to Client Scopes -> Create client scope:
	• Name: groups
	• Type: Default or Optional [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)
• Go to the Mappers tab of that scope -> Configure a new mapper -> By configuration:
	• Mapper Type: Group Membership
	• Name: groupsmapper (this becomes your claim name)
	• Token Claim Name: groupsmapper
	• Uncheck Full group path (so the claim outputs gitea-users instead of /gitea-users). [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)

## Create the OIDC Client

• Go to Clients -> Create client:
	• Client type: OpenID Connect
	• Client ID: gitea (or a name of your choice)
	• Client authentication: On (Confidential client) [1] (https://www.talkingquickly.co.uk/gitea-sso-with-keycloak-openldap-openid-connect), [2] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457), [3] (https://www.youtube.com/watch?v=WGcgiegv0W0)
• Under Client details:
	• Root URL: https://gitea.yourdomain.com/
	• Valid redirect URIs: https://yourdomain.com (replace keycloak with your Gitea authentication source name if different)
	• Web origins: https://gitea.yourdomain.com/ [1] (https://forum.gitea.com/t/gitea-meets-keycloak-gitea-beginner-questions/11011), [2] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)
• Go to the Client Scopes tab of your new client and add the groups client scope you created earlier. [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)
• Go to the Credentials tab and copy the Client Secret. [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457), [2] (https://www.youtube.com/watch?v=WGcgiegv0W0)
• Go to Realm Settings -> Endpoints and note your OpenID Endpoint Configuration discovery URL. [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457)

2. Gitea Configuration Steps


## Gitea Admin GUI Settings

• Navigate to Gitea: Site Administration -> Authentication Sources -> Add Authentication Source:
	• Authentication Type: OAuth2
	• OAuth2 Provider: OpenID Connect
	• Name: keycloak (matches the callback path above)
	• Client ID: gitea (from Keycloak client settings)
	• Client Secret: (paste the Keycloak client secret)
	• OpenID Connect Discovery URL: (paste the discovery URL from Keycloak Realm Settings)
	• Additional Scopes: groups
	• Group Claim Name: groupsmapper
	• Admin Group: gitea-admins
	• Restricted Group: (optional)
	• Enable Auto Register (so users logging in via Keycloak are automatically created in Gitea). [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457), [2] (https://forum.gitea.com/t/gitea-meets-keycloak-gitea-beginner-questions/11011), [3] (https://www.talkingquickly.co.uk/gitea-sso-with-keycloak-openldap-openid-connect)

## Gitea Configuration File (app.ini) Adjustments

Ensure your app.ini (or Docker environment variables) has auto-registration and OpenID settings properly configured:
ini
[server]
ROOT_URL = https://gitea.yourdomain.com/

[oauth2_client]
ENABLE_AUTO_REGISTRATION = true
UPDATE_AVATAR = true
Use code with caution.
For deeper architectural guidance, check out the community guide on Keycloak and Gitea Configuration or review the official Gitea Authentication Documentation. [1] (https://forum.gitea.com/t/guide-keycloak-and-gitea/9457), [2] (https://docs.gitea.com/administration/authentication/)


# Import realm settings

You can also import the realm settings via a JSON file, which bypasses the UI workflow entirely. In Keycloak 26, the UI layout has changed slightly, which is likely why you are missing that specific button. Here is the complete, ready-to-import Keycloak 26 partial realm configuration JSON. It includes the client gitea, the custom client scope groups, the group membership protocol mapper configured properly, and the group definitions.

1. The Realm Import File (gitea-realm-import.json)

Save the following content to a file named gitea-realm-import.json:
json
{
  "realm": "gitea-realm",
  "enabled": true,
  "groups": [
    {
      "name": "gitea-users",
      "path": "/gitea-users",
      "attributes": {},
      "realmRoles": [],
      "clientRoles": {},
      "subGroups": []
    },
    {
      "name": "gitea-admins",
      "path": "/gitea-admins",
      "attributes": {},
      "realmRoles": [],
      "clientRoles": {},
      "subGroups": []
    }
  ],
  "clientScopes": [
    {
      "name": "groups",
      "protocol": "openid-connect",
      "attributes": {
        "display.on.consent.screen": "true",
        "include.in.token.scope": "true"
      },
      "protocolMappers": [
        {
          "name": "groupsmapper",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-group-membership-mapper",
          "consentRequired": false,
          "config": {
            "full.path": "false",
            "id.token.claim": "true",
            "access.token.claim": "true",
            "claim.name": "groupsmapper",
            "userinfo.token.claim": "true"
          }
        }
      ]
    }
  ],
  "clients": [
    {
      "clientId": "gitea",
      "name": "Gitea OIDC Client",
      "description": "",
      "rootUrl": "https://yourdomain.com",
      "adminUrl": "",
      "baseUrl": "",
      "surrogateAuthRequired": false,
      "enabled": true,
      "alwaysDisplayInConsole": false,
      "clientAuthenticatorType": "client-secret",
      "secret": "YOUR_GENERATED_CLIENT_SECRET_HERE",
      "redirectUris": [
        "https://yourdomain.comuser/oauth2/keycloak/callback"
      ],
      "webOrigins": [
        "https://yourdomain.com"
      ],
      "notBefore": 0,
      "bearerOnly": false,
      "consentRequired": false,
      "standardFlowEnabled": true,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": false,
      "serviceAccountsEnabled": false,
      "publicClient": false,
      "frontchannelLogout": true,
      "protocol": "openid-connect",
      "attributes": {
        "oidc.ciba.grant.enabled": "false",
        "client.secret.creation.time": "1710000000",
        "backchannel.logout.session.required": "true",
        "post.logout.redirect.uris": "https://yourdomain.com",
        "display.on.consent.screen": "false",
        "backchannel.logout.revoke.offline.tokens": "false"
      },
      "authenticationFlowBindingOverrides": {},
      "fullScopeAllowed": true,
      "nodeReRegistrationTimeout": -1,
      "defaultClientScopes": [
        "web-origins",
        "acr",
        "roles",
        "profile",
        "groups",
        "email"
      ],
      "optionalClientScopes": [
        "address",
        "phone",
        "offline_access",
        "microprofile-jwt"
      ]
    }
  ]
}
Use code with caution.

2. How to Import it

You have two choices to import this file depending on whether you want to do it via the UI or directly on startup via Docker:

Option A: Import via Keycloak 26 Admin UI

1. Log into your Keycloak Admin Console.
2. Click the Realm drop-down menu in the top-left corner (it usually shows master).
3. Click Create Realm.
4. Instead of typing a name, look for the Resource file upload option. Click Browse... or Select file and upload the gitea-realm-import.json.
5. Keycloak will parse the file and auto-fill the field. Adjust the realm name if desired, then click Create.

Option B: Import on Startup (Docker)

If you want Keycloak to load this configuration completely hands-free when the container spins up:
1. Mount the JSON file into the Keycloak container's import directory: /opt/keycloak/data/import/.
2. Add the --import-realm flag to your Keycloak startup command.
Example Docker Compose snippet:
yaml
services:
  keycloak:
    image: quay.io/keycloak/keycloak:26.0
    command: start-dev --import-realm
    volumes:
      - ./gitea-realm-import.json:/opt/keycloak/data/import/gitea-realm-import.json
    # ... rest of your configuration
Use code with caution.

🛠️ Post-Import Notes for Keycloak 26

• Client Secret: In the configuration file above, replace YOUR_GENERATED_CLIENT_SECRET_HERE with your preferred strong secret, or let Keycloak auto-generate a new one after import by navigating to Clients -> gitea -> Credentials tab.
• Domain Names: Update https://yourdomain.com inside the JSON file to your actual Gitea deployment URL before importing.
Let me know:
• Would you prefer to import this directly into an existing realm instead of creating a brand new one?
• Do you need help mapping existing Keycloak users to the newly imported gitea-users and gitea-admins groups inside the JSON file?
