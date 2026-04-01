-- Procedimiento que genera el endoso de traspaso de cartera
-- Creado: 08/05/2017 - Autor: Román Gordón
-- Modificado:   23/08/2019  - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro409a()

-- Prueba 
drop procedure ap_pro409a;
create procedure ap_pro409a()
returning	char(20),
            char(10),
			char(5),
			char(5),
			date,
			smallint;

define _descripcion		varchar(200);
define _error_desc		varchar(50);
define _no_documento    char(20);
define _no_poliza		char(10);
define _cod_impuesto	char(3);
define _periodo			char(7);
define _cod_agente_new	char(5);
define _cod_agente_old	char(5);
define _no_endoso		char(5);
define _cod_tipocalc	char(3);
define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _factor_impuesto	dec(16,2);
define _prima_suscrita	dec(16,2);
define _prima_retenida	dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_neta		dec(16,2);
define _descuento		dec(16,2);
define _impuesto		dec(16,2);
define _recargo			dec(16,2);
define _prima			dec(16,2);
define _estatus_poliza	smallint;
define _cnt_ren			smallint;
define _cnt_agt			smallint;
define _cnt_agt_25      smallint;  --AMORENO cod_agente: 02569
define _error_isam		integer;
define _error			integer;
define _fecha_efectiva	date;

--set debug file to "sp_pro409a.trc";
--trace on;


set isolation to dirty read;


foreach with hold
	select no_documento,
		   cod_agente_old,
		   cod_agente_new,
		   fecha_efectiva
	  into _no_documento,
		   _cod_agente_old,
		   _cod_agente_new,
		   _fecha_efectiva
	  from deivid_tmp:traspasos_corredor
	 where procesado = 0
	 order by 2,1

	let _no_poliza = sp_sis21(_no_documento);

	
	select estatus_poliza,
           vigencia_inic	
	  into _estatus_poliza,
	       _fecha_efectiva
	  from emipomae
	 where no_poliza = _no_poliza;


	return trim(_no_documento),
           _no_poliza,
		   _cod_agente_old,
		   _cod_agente_new,
		   _fecha_efectiva,
           _estatus_poliza  with resume;

end foreach



end procedure;