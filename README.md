# Práctica final CNVR

## Misc

Para que OpenStack tenga conectividad hacia internet, hay que habilitar el masquerading via iptables
de la interfaz que aporta dicha conectividad al host, en su defecto __eth0__.

```bash
sudo iptables -t nat -A POSTROUTING -o enx9cebe83546da -j MASQUERADE
```

Hay que copiar la carpeta de cloud-inti a controller (o utilizar los comandos openstack desde aquí)

```bash
scp -r cloud-init root@controller:.
```
