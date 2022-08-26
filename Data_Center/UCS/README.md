# Notes on UCS

## UCS PowerTool
Is a library of PowerShell Cmdlets that enavles management of UCS environments from Microsoft OS by using the **UCS XML API**.

UCS Manager is the service that provides the XML API endpoint along with a graphical interface and a command line. The UCS components, both physical and logical, are represented as XML objects in a hierarchical Object Model format and can be manipulated via the XML API.

All **UCS objects** are described in an XML schema.

## UCS Python SDK
The sdk is called **ucsmsdk**.

We can use the UcsHandle class from ucshandle module to connect and disconnect from a UCS Manager.
```
#Establish a session
from ucsmsdk.ucshandle import UcsHandle
handle = UcsHandle("ip", "admin", "password")
handle.login()

#Query all objects of Class ID "computerBlade"
blades = handle.query_classid("computerBlade")
for blade in blades:
  print(blade.dn, blade.num_of_cpus, blade.available_memory)
```
For the UCS Manager Python SDK there are 5 query methods:
| Method | Returns |
| ------ | ------- |
| query_classid | A list of objects, the list may contain zero objects. |
| query_classids | A dictionary where the classid is the key and a list of zero or more. |
| query_dn | Zero or one object |
| query_dns | Returns a dictionary where the Dn is the key and the object is the value. If the Dn does not exist the value for that key will be None. |
| query_childre | A list of zero or more objects |















