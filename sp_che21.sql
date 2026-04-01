-- Actualizacion para Reclamos de Salud

-- Creado    : 05/10/2001 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/11/2001 - Autor: Demetrio Hurtado Almanza

--drop procedure sp_che21;

create procedure "informix".sp_che21()
returning char(100),
          integer;

define a_no_reclamo		char(10);
define _cod_reclamante	char(10);
define _fecha_siniestro	char(10);
define _numrecla		char(20);
define _no_poliza		char(10);
define _no_documento	char(20);
define _nombre_recla	char(100);
define _descripcion		char(100);
define _lenght			integer;
define _transaccion		char(10);

define _cantidad		integer;

SET ISOLATION TO DIRTY READ;

let _cantidad = 0;

foreach
 select	no_reclamo,
        transaccion
   into a_no_reclamo,
        _transaccion
   from rectrmae
  where numrecla[1,7] = "18-1003"

	let _cantidad = _cantidad + 1;

--	if _cantidad > 10 then
--		exit foreach;
--	end if

	select cod_reclamante,
		   fecha_siniestro,
		   numrecla,
		   no_poliza	
	  into _cod_reclamante,
		   _fecha_siniestro,
		   _numrecla,
		   _no_poliza	
	  from recrcmae
	 where no_reclamo = a_no_reclamo;

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_recla
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	let _descripcion = TRIM(_no_documento) || 
					   "  " || TRIM(_numrecla) ||
					   "  " || TRIM(_transaccion) ||
					   "  " || TRIM(_fecha_siniestro) ||
	                   "  " || TRIM(_nombre_recla);

	let _lenght = length(_descripcion);

	return _descripcion,
		   _lenght
		   with resume;

end foreach

end procedure;