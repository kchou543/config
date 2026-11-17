To set up MX, SPF, DKIM, and DMARC records on Dynu, log in to the Dynu Control Panel, select DDNS Services, click your domain name, and open the DNS Records tab. All four email records are created there using MX and TXT record types. [1] (https://www.dynu.com/it-IT/FAQ/Dynamic-DNS-Service), [2] (https://www.dynu.com/it-IT/Resources/Tutorials/DynamicDNS/CreateMXRecord), [3] (https://www.dynu.com/Resources/Tutorials/DynamicDNS/CreateMXRecord)
(Note: Replace yourdomain.com and mail.yourdomain.com below with your actual Dynu hostname or custom domain).

# 1. Create an A Record for Your Mail Subdomain

Before creating an MX record, your mail server hostname must point to your server's IP address. [1] (https://www.dynu.com/Resources/DNS-Records/MX-Record)
- Node Name. Enter mail (this creates mail.yourdomain.com).
- Type. Select A (or AAAA for IPv6).
- IP Address. Enter your server's public IP address (enable Dynamic DNS updates for this node if your IP changes).
- TTL. Leave at the default (e.g., 90 or 300 seconds). [1] (https://www.dynu.com/it-IT/Resources/Tutorials/DynamicDNS/CreateDDNSRecords), [2] (https://www.dynu.com/Resources/DNS-Records/MX-Record)

# 2. Create the MX Record (Incoming Mail Routing)

The Dynu MX record tells external mail servers where to deliver incoming emails. [1] (https://www.dynu.com/Resources/Tutorials/DynamicDNS/CreateMXRecord), [2] (https://www.dynu.com/Resources/DNS-Records/MX-Record)
- Node Name. Leave empty (this applies the record to your root domain yourdomain.com).
- Type. Select MX.
- Hostname. Enter mail.yourdomain.com. (Do not point an MX record to a CNAME).
- Priority. Enter 10.
- TTL. Enter 3600 (or leave default). [1] (https://www.dynu.com/it-IT/Resources/Tutorials/DynamicDNS/CreateMXRecord), [2] (https://www.dynu.com/Resources/DNS-Records/MX-Record)

# 3. Create the SPF Record (Authorized Senders)

SPF specifies which IP addresses or servers are allowed to send emails on behalf of your domain. Add this as a TXT record. [1] (https://www.dynu.com/Resources/Tutorials/DynamicDNS/CreateTXTRecord), [2] (https://www.dynu.com/en-US/Blog/Article?Article=Safeguard-your-emails-with-SPF-DKIM-and-DMARC), [3] (https://www.dynu.com/Resources/DNS-Records/TXT-Record)
- Node Name. Leave empty.
- Type. Select TXT.
- Text. Enter:text
v=spf1 mx a:mail.yourdomain.com -all
Use code with caution.
- TTL. Enter 3600. [1] (https://www.dynu.com/Resources/Tutorials/DynamicDNS/CreateTXTRecord)

# 4. Create the DKIM Record (Cryptographic Email Signing)

DKIM adds a digital signature to outgoing emails. First, generate your DKIM keypair inside your Docker mail server container (for example, docker exec -ti mailserver setup config dkim in Docker Mailserver), then copy the public key string (p=...). [1] (https://www.dynu.com/fr-FR/Blog/Article?Article=Safeguard-your-emails-with-SPF-DKIM-and-DMARC), [2] (https://www.dynu.com/Resources/Tutorials/EmailServices/EmailServiceSetup/FullServiceEmail), [3] (https://www.dynu.com/Resources/Tutorials/DynamicDNS/CreateTXTRecord)
- Node Name. Enter mail._domainkey. (Replace mail if your mail server uses a different selector, such as default._domainkey).
- Type. Select TXT.
- Text. Paste your full public key record:text
v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
Use code with caution.
(Note: Remove any quotation marks or line breaks from the p= key string so it sits on one continuous line).
- TTL. Enter 3600. [1] (https://www.dynu.com/Resources/Tutorials/EmailServices/EmailServiceSetup/FullServiceEmail)

# 5. Create the DMARC Record (Policy & Reporting)

DMARC tells receiving servers how to handle emails that fail SPF or DKIM checks. [1] (https://www.dynu.com/en-US/Blog/Article?Article=Safeguard-your-emails-with-SPF-DKIM-and-DMARC), [2] (https://www.dynu.com/fr-FR/Blog/Article?Article=Safeguard-your-emails-with-SPF-DKIM-and-DMARC)
- Node Name. Enter _dmarc.
- Type. Select TXT.
- Text. Start with a monitoring policy (p=none) while testing:text
v=DMARC1; p=none; rua=mailto:postmaster@yourdomain.com; adkim=r; aspf=r
Use code with caution.
(Once you confirm legitimate emails pass authentication, change p=none to p=quarantine or p=reject).
- TTL. Enter 3600. [1] (https://www.dynu.com/fr-FR/Blog/Article?Article=Safeguard-your-emails-with-SPF-DKIM-and-DMARC), [2] (https://www.dynu.com/it-IT/FAQ/Dynamic-DNS-Service)

**Quick Reference Summary**


| Record	| Node Name	      | Type | Value / Target                                         |
| --------- | --------------- | ---- | ------------------------------------------------------ |
| A	        | mail	          | A	 | YOUR_PUBLIC_IP                                         |
| MX	    | (empty)	      | MX	 | mail.yourdomain.com (Priority: 10)                     |
| SPF	    | (empty)	      | TXT	 | v=spf1 mx a:mail.yourdomain.com -all                   |
| DKIM	    | mail._domainkey | TXT	 | v=DKIM1; h=sha256; k=rsa; p=YOUR_PUBLIC_KEY            |
| DMARC	    | _dmarc	      | TXT	 | v=DMARC1; p=none; rua=mailto:postmaster@yourdomain.com |


Important Caveat for Dynamic IPs & Residential ISPs

- Reverse DNS (PTR). Dynu manages forward DNS (yourdomain.com -> IP), but only your ISP or VPS provider controls Reverse DNS (IP -> mail.yourdomain.com). Major providers like Gmail and Microsoft will reject or spam-folder outbound mail if your IP lacks a matching PTR record or sits on a residential IP blocklist.
- Verification. After saving your records, use the Dynu DNS Lookup Tool to verify that each record resolves properly. [1] (https://www.dynu.com/Resources/Tutorials/EmailServices/EmailServiceSetup/FullServiceEmail), [2] (https://www.dynu.com/it-IT/FAQ/Dynamic-DNS-Service)
