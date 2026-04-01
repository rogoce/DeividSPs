-- Procedimiento que Genera el Numero de Endoso Externo (Cuando esta Actualizado)
-- 
-- Creado    : 14/09/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/09/2001 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis30a;

create procedure sp_sis30a(a_year char(4))
returning char(5);

define _fecha_siniestro date;
define _ano_siniestro	char(4);

let _fecha_siniestro = today;

let _ano_siniestro = year(_fecha_siniestro);

if _ano_siniestro = a_year then

	return 'exito';

else

	return 'fraca';

end if

end procedure;