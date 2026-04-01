select p.*,c.nombre from parmailsend p, parmailtipo c
where p.cod_tipo = c.cod_tipo
and p.cod_tipo = '00031'
and p.secuencia = 3292058
and p.secuencia in(
select mail_secuencia from parmailcomp
where no_documento = '0217-00400-10')
