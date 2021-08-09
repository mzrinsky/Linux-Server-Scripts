## Helpful Linux Server Scripts

These are some of my scripts I use on my Linux servers.

If you find these useful, consider showing you care.

<a href='https://ko-fi.com/A0A74VYT1' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi2.png?v=2' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

### ipset_add.bash

A helper script to add an address to an ipset if it does NOT already match in the set.

Usage:
```bash
# add <address> to <set_name> if it does NOT already match an address in <set_name>
ipset_add.bash <set_name> <address>
```

### ipset_generate.bash

This script will generate an ipset from a file of ip addresses.
It will convert addresses ending in .0 to a /24 and avoid adding any duplicates or addresses which already match.

example: `1.2.3.0` will be converted to `1.2.3.0/24` and `1.2.3.2` would not be added to the set, as it already matches `1.2.3.0/24`.

It will tell you at the end of a run how many addresses were skipped and what % of the list of addresses that was.
It also **skips ipv6 addresses** however these do NOT affect the count of skipped addresses.
It is safe to run this when updating a set, as it first adds the addresses to a temporary set, and then swaps them in place of the actual set.

example: importing to a set named `myset` will first create `tmp-myset` and once full of addresses will be swapped via. `ipset swap` to `myset`.

example output: `Skipped 10889 of 12598 or 86 %`

Usage:
```bash
# create an ipset named <set_name> from the list of ip addresses in <address_file>.
ipset_generate.bash <set_name> <address_file>
```

### ipset_save.bash

Save all ipsets to a file.
IPsets starting with `f2b-` or `tmp-` will be ignored. (fail2ban saves and restores it's own sets and tmp- sets are temporary..)

Usage:
```bash
# save all ipsets to <filename> it will skip ipsets starting with f2b- and tmp-
ipset_save.bash <filename>

# if no filename is given ipsets will be saved to /etc/sysconfig/ipset
ipset_save.bash
```
