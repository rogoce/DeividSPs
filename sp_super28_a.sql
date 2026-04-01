--Data
--Armando Moreno M.
--execute procedure sp_super28('2025-01','2025-06')

DROP procedure sp_super28_a;
CREATE procedure sp_super28_a()

RETURNING	char(18)		as reclamo,
            char(20)		as poliza,
			varchar(50)		as asegurado,
			char(9)		    as estatus_reclamo,
			char(50)        as evento,
			date            as vigencia_inic,
			date			as vigencia_final,
			date			as fecha_reclamo,
			dec(16,2)		as monto_pagado,
			varchar(50)     as corredor,
			date			as fecha_siniestro,
			date			as fecha_pago,
			char(2)		    as es_coaseguro,
			char(10)		as no_tramite;

define _filtro					varchar(255);
define _motivo_declinacion	    varchar(50);
define _n_cobertura			    varchar(50);
define _n_agente				varchar(50);
define _n_evento				varchar(50);
define _n_aseg					varchar(50);
define _estatus_rec			    varchar(30);
define _no_documento			char(20);
define _numrecla				char(18);
define _no_reclamo			    char(10);
define _no_poliza,_no_tramite	char(10);
define _estatus_reclamo		    char(9);
define _cod_agente				char(5);
define _es_coas					char(2);
define _cod_evento				char(3);
define _cod_tipoprod			char(3);
define _nueva_renov				char(1);
define _estatus_audiencia		smallint;
define _m_pagado			dec(16,2);
define _fecha_pago			date;
define _fecha_siniestro		date;
define _fecha_reclamo		date;
define _v_inic				date;
define _v_final				date;
define  _cod_asegurado      char(10);

set isolation to dirty read;
foreach
	select rec.numrecla,
		   rec.no_documento,
		   rec.cod_asegurado,
		   decode(rec.estatus_reclamo,"A","ABIERTO","C","CERRADO","D","DECLINADO","N","NO APLICA"),
		   rec.cod_evento,
		   rec.no_poliza,
		   rec.fecha_reclamo,
		   rec.fecha_siniestro,
		   rec.no_reclamo,
		   rec.no_tramite
	  into _numrecla,
		   _no_documento,
		   _cod_asegurado,
		   _estatus_reclamo,
		   _cod_evento,
		   _no_poliza,
		   _fecha_reclamo,
		   _fecha_siniestro,
		   _no_reclamo,
		   _no_tramite
	  from recrcmae rec
	 where rec.actualizado = 1
	   and rec.fecha_reclamo between '01/01/2025' and '30/11/2025'
	   and numrecla[1,2] in('02','20','23')
	   order by rec.fecha_reclamo
	   
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;
	 
	select nombre
	  into _n_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	 
	select vigencia_inic,
	       vigencia_final,
		   cod_tipoprod
	  into _v_inic,
           _v_final,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	
	let _es_coas = 'NO';
	if _cod_tipoprod in('001','002') then
		let _es_coas = 'SI';
	end if
	
	let _m_pagado = 0.00;
	
	select sum(pagos)
	  into _m_pagado
	  from recrccob
	 where no_reclamo = _no_reclamo;

	select cod_agente
	  into _cod_agente
	  from emipoliza
	 where no_documento = _no_documento;

	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	let _fecha_pago = null;
	
	select max(fecha_pagado)
	  into _fecha_pago
	  from rectrmae
     where actualizado = 1
       and numrecla = _numrecla
       and anular_nt is null;
	   
	return _numrecla,
		   _no_documento,
           _n_aseg,
		   _estatus_reclamo,
		   _n_evento,
		   _v_inic,
		   _v_final,
		   _fecha_reclamo,
		   _m_pagado,
		   _n_agente,
  		   _fecha_siniestro,
		   _fecha_pago,                   
           _es_coas,
		   _no_tramite with resume;
	end foreach
END PROCEDURE;
