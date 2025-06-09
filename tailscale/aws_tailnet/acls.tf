resource "tailscale_acl" "as_json" {
  overwrite_existing_content = true
  acl = jsonencode( // Example/default ACLs for unrestricted connections.
    {
      // Declare static groups of users. Use autogroups for all users or users with a specific role.
      // "groups": {
      //  	"group:example": ["alice@example.com", "bob@example.com"],
      // },

      // Define the tags which can be applied to devices and by which users.
      "tagOwners" : {
        "tag:ssh" : ["autogroup:admin"],
        "tag:server" : ["autogroup:admin"],  // Allows all :53, :67, :8888
        "tag:webhost" : ["autogroup:admin"], // Allows all :80, :443
        "tag:it" : ["autogroup:admin"],
        "tag:promiscuous" : ["autogroup:admin"],
        "tag:nextdns" : ["autogroup:admin"], // Sets up a name -> aws route in NextDNS

        // Required for kubernetes tailscale integration
        "tag:k8s-operator" : [],
        "tag:k8s" : ["tag:k8s-operator"],
      },

      // Define grants that govern access for users, groups, autogroups, tags,
      // Tailscale IP addresses, and subnet ranges.
      "grants" : [
        // Allow all connections.
        // Comment this section out if you want to define specific restrictions.
        // {"src": ["*"], "dst": ["*"], "ip": ["*"]},

        // Allow users in "group:example" to access "tag:example", but only from
        // devices that are running macOS and have enabled Tailscale client auto-updating.
        // {"src": ["group:example"], "dst": ["tag:example"], "ip": ["*"], "srcPosture":["posture:autoUpdateMac"]},

        // Allow all connections for admins
        { "src" : ["autogroup:admin"], "dst" : ["*"], "ip" : ["*"] },
        // Anyone can access webhost 80, 443
        { "src" : ["*"], "dst" : ["tag:webhost"], "ip" : ["80", "443"] },
        // IT infrastructure can contact any device and any port. Use this tag for critical IT
        { "src" : ["tag:it"], "dst" : ["*"], "ip" : ["*"] },
        // Members can access their own devices and any public IP
        { "src" : ["autogroup:member"], "dst" : ["autogroup:self", "autogroup:internet"], "ip" : ["*"] },
        { "src" : ["*"], "dst" : ["192.168.0.110"], "ip" : ["*"] },
        // Accepts all incoming connections
        { "src" : ["*"], "dst" : ["tag:promiscuous"], "ip" : ["*"] },
        { "src" : ["*"], "dst" : ["tag:k8s"], "ip" : ["*"] },
        { "src" : ["tag:k8s"], "dst" : ["*"], "ip" : ["*"] },
      ],

      // Define postures that will be applied to all rules without any specific
      // srcPosture definition.
      // "defaultSrcPosture": [
      //      "posture:anyMac",
      // ],

      // Define device posture rules requiring devices to meet
      // certain criteria to access parts of your system.
      // "postures": {
      //      // Require devices running macOS, a stable Tailscale
      //      // version and auto update enabled for Tailscale.
      // 	"posture:autoUpdateMac": [
      // 	    "node:os == 'macos'",
      // 	    "node:tsReleaseTrack == 'stable'",
      // 	    "node:tsAutoUpdate",
      // 	],
      //      // Require devices running macOS and a stable
      //      // Tailscale version.
      // 	"posture:anyMac": [
      // 	    "node:os == 'macos'",
      // 	    "node:tsReleaseTrack == 'stable'",
      // 	],
      // },

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
          "action" : "accept",
          "src" : ["autogroup:admin"],
          "dst" : ["tag:ssh"],
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
  })
}
