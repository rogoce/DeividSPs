--**********************************
-- Reporte para sacar primas por cobrar al 30/09/2011 para Leiry
-- *********************************
-- fecha: 07/11/2011

DROP PROCEDURE sp_aud24;
CREATE PROCEDURE sp_aud24()
RETURNING   CHAR(10),  
			varchar(100),
			varchar(50),
			char(20),
			date,
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			date;

define _no_documento	char(20);
define _cod_pagador     char(10);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);
define _nombre_cli      varchar(100);
define _direccion_1	    varchar(50);
define _direccion_2	    varchar(50);
define _fecha_ult_pago 	date;
define _no_poliza       char(10);
define _prima_bruta    	DEC(16,2);
define _fecha_sus       date;

 
SET ISOLATION TO DIRTY READ;

let v_por_vencer = 0;
let v_exigible   = 0; 
let v_corriente	 = 0;
let v_monto_30   = 0;
let v_monto_60   = 0;
let v_monto_90	 = 0;
let v_saldo		 = 0;
let _prima_bruta = 0;
let	_nombre_cli  = "";
let	_direccion_1 = "";
let	_direccion_2 = "";
let _fecha_ult_pago = "";

FOREACH	
 select no_documento,
		cod_pagador
   into	_no_documento,
		_cod_pagador
   from emipoliza

  CALL sp_cob33(
  '001',
  '001',
  _no_documento,
  '2011-10',
  '31/10/2011'
  ) RETURNING v_por_vencer,
		      v_exigible,  
		      v_corriente,
		      v_monto_30,  
		      v_monto_60,  
		      v_monto_90,
		      v_saldo
		      ;

if v_saldo = 0 then
	continue foreach;
end if

let _no_poliza = sp_sis21(_no_documento);

select fecha_suscripcion,
       prima_bruta
  into _fecha_sus,
       _prima_bruta
  from emipomae
 where no_poliza = _no_poliza;

  if _cod_pagador is null then
    select cod_pagador
	  into _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

  end if

  select nombre,
         direccion_1,
         direccion_2
    into _nombre_cli,
         _direccion_1,
         _direccion_2
	from cliclien
   where cod_cliente = _cod_pagador;

	foreach
	 select fecha
	   into _fecha_ult_pago
	   from cobredet
	  where doc_remesa  = _no_documento
	    and actualizado = 1
	    and tipo_mov    = "P"
		and periodo     = '2011-10'					--	    and periodo     <= '2011-09'
	  order by fecha desc
		
		exit foreach;
		
	end foreach		

	if _fecha_ult_pago is null then

		select min(fecha_primer_pago)
		  into _fecha_ult_pago
		  from emipomae
		 where no_documento = _no_documento;

	end if 

	if _fecha_ult_pago is null then

		select min(fecha_suscripcion)
		  into _fecha_ult_pago
		  from emipomae
		 where no_documento = _no_documento;

	end if

	if _direccion_1 is null or _direccion_1 = "" then
	   let _direccion_1 = _direccion_2;	
	end if

  RETURN _cod_pagador,
		 _nombre_cli,
		 _direccion_1,
		 _no_documento,
		 _fecha_sus,
		 _prima_bruta,
		 v_saldo,
		 v_corriente,
		 v_monto_30, 
		 v_monto_60, 
		 v_monto_90,
		 _fecha_ult_pago
    	 WITH RESUME;

END FOREACH;


END PROCEDURE
  