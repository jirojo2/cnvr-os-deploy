# Práctica final CNVR

## Prerrequisitos

Suponiendo que tenemos la `v05` de `openstack_tutorial-mitaka_4n_classic_ovs`, provista por la asignatura CNVR:

Actualizamos en el segmento `load-img` de `openstack_tutorial.xml` la versión de Ubuntu Cloud a `Xenial`.

```bash
sudo vnx -f openstack_tutorial.xml -v --create
sudo vnx -f openstack_tutorial.xml -v -x start-all
sudo vnx -f openstack_tutorial.xml -v -x load-img
```

## Instrucciones para lanzar el escenario

Para lanzar el escenario, suponiendo que se ha lanzado el entorno VNX:

```bash
ssh root@controller 'bash -s' < create-scenario.sh
ssh root@controller 'bash -s' < create-s3.sh
ssh root@controller 'bash -s' < activate-adm-ssh.sh
```

Para destruir el escenario y habilitar/deshabilitar accesos, se encuentran disponibles varios scripts en este repositorio.

## Notas

Para que OpenStack tenga conectividad hacia internet, hay que habilitar el masquerading via iptables
de la interfaz que aporta dicha conectividad al host, en su defecto __eth0__.

```bash
sudo iptables -t nat -A POSTROUTING -o enx9cebe83546da -j MASQUERADE
```
