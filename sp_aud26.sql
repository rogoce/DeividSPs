--**********************************
-- Reporte para sacar las primas suscritas de enero a sept 2011 para Leiry
-- *********************************
-- fecha: 07/11/2011

DROP PROCEDURE sp_aud26;
CREATE PROCEDURE sp_aud26()
RETURNING   CHAR(20),  
			date,
			date,
			char(10),
			date,
			DEC(16,2);

define _no_documento	char(20);
DEFINE _prima_suscrita      DEC(16,2);
define _direccion_1	    varchar(50);
define _direccion_2	    varchar(50);
define _fecha_ult_pago 	date;
define _no_poliza       char(10);
define _filtros         varchar(255);
define _numrecla       	char(18);
define _no_reclamo      char(10);
define _fecha_reclamo   date;
define _no_factura      char(10);
define _fecha_suscripcion date;
define _vig_inic          date;
define _vig_fin          date;

 
SET ISOLATION TO DIRTY READ;

let _prima_suscrita = 0;


--***************
-- Prima Suscrita
--***************
foreach
 select no_documento,
		sum(prima_suscrita)
   into _no_documento,
		_prima_suscrita
   from endedmae
  where actualizado  = 1
	and periodo between '2011-10' and '2011-10'
  group by no_documento

  let _no_poliza = sp_sis21(_no_documento);
 

  select no_factura,
         fecha_suscripcion,
		 vigencia_inic,
		 vigencia_final
    into _no_factura,
	     _fecha_suscripcion,
		 _vig_inic,
		 _vig_fin
	from emipomae
   where no_poliza = _no_poliza;


  RETURN _no_documento,
		 _vig_inic,
		 _vig_fin,
		 _no_factura,
		 _fecha_suscripcion,
		 _prima_suscrita
    	 WITH RESUME;

END FOREACH;


END PROCEDURE
  