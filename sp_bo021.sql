-- Fecha del Ultimo Pago para Subir a BO 
-- 
-- Creado    : 19/06/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/06/2004 - Autor: Demetrio Hurtado Almanza
--

drop procedure sp_bo021;

create procedure "informix".sp_bo021(a_periodo char(7))
returning integer,
          char(50);

define _fecha_ult_pago	date;
define _monto_ult_pago	dec(16,2);
define _no_documento	char(20);
define _no_poliza		varchar(10);
define _facultativo     smallint;

set isolation to dirty read;

foreach
 select no_documento
   into _no_documento
   from cobmoros4
  where periodo = a_periodo
    --and no_documento = '0216-00030-01'

	let _fecha_ult_pago = null;
	let _monto_ult_pago = 0.00;
	
	--Henry_14092017, retorna si la poliza es facultativo.
	let _facultativo = 0; 
	call sp_sis21(_no_documento) returning _no_poliza;
	let _facultativo   = sp_sis439(_no_poliza);	
	if _facultativo is null then
		let _facultativo = 0; 	   
	end if	
	

	foreach
	 select fecha,
	        monto
	   into _fecha_ult_pago,
	        _monto_ult_pago
	   from cobredet
	  where doc_remesa  = _no_documento
	    and actualizado = 1
	    and tipo_mov    = "P"
	    and periodo     <= a_periodo
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

	update cobmoros4
	   set fecha_ult_pago = _fecha_ult_pago,
	       monto_ult_pago = _monto_ult_pago,
		   facultativo = _facultativo  -- adicioon de 1 si es facultativo,HG
	 where no_documento   = _no_documento
	   and periodo		  = a_periodo;

end foreach

return 0, "Actualizacion Exitosa";

end procedure