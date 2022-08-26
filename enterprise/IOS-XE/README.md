# IOS-XE Notes
## NETCONF
### Feature Commands
To enable NETCONf on IOS-XE do the following:
```
netconf-yang
```

### Authentication
It notest that NETCONF connections should be authenticated using AAA credentials with privilege level 15 access allowed.

## RESTCONF
### Authentication
IS the same for NETCONF

### Access
RESTCONF runs over HTTPS and to enable support for RESTCONF over port 443 we have to issue the command:
```
ip http secure-server
```

### Feature Commands
To enable RESTCONF on the CLI use:
```
restconf
```








