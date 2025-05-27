resource "tailscale_acl" "as_json" {
  acl = jsonencode(// Example/default ACLs for unrestricted connections.
    {
      "groups" : {
        "group:server_admins" : [
          var.admin_user,
        ],
      },

      // Define the tags which can be applied to devices and by which users.
      "tagOwners" : {
        "tag:server" : ["autogroup:admin"], // Allows all :53, :67, :8888
        "tag:webhost" : ["autogroup:admin"], // Allows all :80, :443
        "tag:it" : ["autogroup:admin"],
        "tag:promiscuous" : ["autogroup:admin"],
        "tag:nextdns" : ["autogroup:admin"], // Sets up a name -> aws route in NextDNS
      },

      // Define access control lists for users, groups, autogroups, tags,
      // Tailscale IP addresses, and subnet ranges.
      "acls" : [
        // Allow all connections for admins
        { "action" : "accept", "src" : ["autogroup:admin"], "dst" : ["*:*"] },
        // All users can access webhost 80, 443
        { "action" : "accept", "src" : ["autogroup:member"], "dst" : ["tag:webhost:80,443"] },
        // IT infrastructure can contact any device and any port. Use this tag for critical IT
        { "action" : "accept", "src" : ["tag:it"], "dst" : ["*:*"], },
        // Members can access their own devices and any public IP
        { "action" : "accept", "src" : ["autogroup:member"], "dst" : ["autogroup:self:*", "autogroup:internet:*"], },
        // Accepts all incoming connections
        { "action" : "accept", "src" : ["*"], "dst" : ["tag:promiscuous:*"], },
      ],

      // Define users and devices that can use Tailscale SSH.
      "ssh" : [
        // Allow all users to SSH into their own devices in check mode.
        // Comment this section out if you want to define specific restrictions.
        {
          "action" : "check",
          "src" : ["autogroup:member"],
          "dst" : ["autogroup:self"],
          "users" : ["autogroup:nonroot", "root"],
        },
        // Allow admin users to ssh into any server with any username
        {
          "action" : "check",
          "src" : ["group:server_admins"],
          "dst" : ["tag:it", "tag:server"],
          "users" : ["autogroup:nonroot", "root"],
        },
      ],
      "nodeAttrs" : [
        { "target" : ["100.127.19.131"], "attr" : ["mullvad"] },
        { "target" : ["100.78.202.73"], "attr" : ["mullvad"] },
        { "target" : ["100.66.187.59"], "attr" : ["mullvad"] },
        { "target" : ["100.116.50.88"], "attr" : ["mullvad"] },
        { "target" : ["100.75.39.82"], "attr" : ["mullvad"] },
        { "target" : ["100.68.126.56"], "attr" : ["mullvad"] },
      ],

      "hosts" : {
        "overwatch" : "100.101.130.75",
        "unifi-cal" : "100.111.168.48",
        "pikvm" : "100.84.105.73"
      },

      "tests" : [
        // Tests if autogroup:member can access any exit node
        {
          "src" : var.member_user,
          "accept" : ["1.1.1.1:443", "8.8.8.8:443"],
        },
        // Test if autogroup:member can access webhosts
        {
          "src" : var.member_user,
          "accept" : ["overwatch:443", "unifi-cal:443",],
        },
        // Test if overwatch can access webhosts
        {
          "src" : "overwatch",
          "accept" : ["pikvm:443"],
        },
      ],
    })
}
