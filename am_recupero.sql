--Auditoria de recuperos solicitado por Mayra Robles.
  
drop procedure am_recupero;
create procedure am_recupero()
returning char(5)   as no_recupero,
          char(18)  as reclamo,
		  char(20)  as poliza,
		  char(100) as titular,
		  char(10)  as usuario,
		  dec(16,2) as total_pagado,
		  dec(16,2) as recuperado,
		  dec(16,2) as saldo,
		  char(18)  as estatus,
		  char(50)  as abogado,
		  date      as f_recupero,
		  date      as f_resolucion,
		  date      as f_prescripcion,
		  date      as f_envio_doc,
		  date      as f_siniestro;
			
DEFINE v_recupero   	  CHAR(5);
DEFINE v_asegurado        CHAR(100);
DEFINE v_reclamo          CHAR(18);
DEFINE v_fech_resol       DATE;
DEFINE _fecha_envio,_fecha_siniestro       DATE;
DEFINE v_tercero	      CHAR(100);
DEFINE v_monto_auto       DEC(16,2);
DEFINE _n_abogado  			CHAR(50);

DEFINE _cod_abogado      CHAR(3);
DEFINE _no_reclamo       CHAR(10);      
DEFINE _no_poliza        CHAR(10);
DEFINE _cod_cliente	     CHAR(10);
DEFINE _deducible        DEC(16,2);
DEFINE _pagado_reclamo   DEC(16,2);
DEFINE _saldo			   DEC(16,2);
DEFINE _monto_recuperado       DEC(16,2);
define _numrecla		 char(18);
define _n_tercero        char(100);
define _usuario          char(8);
define _estatus          smallint;
define _no_documento     char(20);

DEFINE _fecha_recupero,_fecha_prescrip	 DATE;
DEFINE _monto_tot,_monto_arreglo		 DEC(16,2);
define _reclamo_tercero,_n_estatus char(18);
define _transaccion     char(10);
define _tran_rec		char(10);
define _no_tranrec		char(10);
define _no_requis     char(10);
define _no_remesa		char(10);

set isolation to dirty read;

let _saldo = 0.00;
foreach
	SELECT no_recupero,
 		   no_reclamo,
           fecha_resolucion,
		   nombre_tercero,
		   pagado_reclamo,
		   fecha_recupero,
		   numrecla,
		   user_added,
		   monto_recuperado,
		   monto_arreglo - monto_recuperado,
		   estatus_recobro,
		   cod_abogado,
		   fecha_prescrip,
		   fecha_envio
  	  INTO v_recupero,
	       _no_reclamo,
		   v_fech_resol,
		   v_tercero,
		   _pagado_reclamo,
		   _fecha_recupero,
		   v_reclamo,
		   _usuario,
		   _monto_recuperado,
		   _saldo,
		   _estatus,
		   _cod_abogado,
		   _fecha_prescrip,
		   _fecha_envio
   	  FROM recrecup
  	 WHERE fecha_recupero >= '01/01/2022'
	   AND fecha_recupero <= '30/06/2022'

	select fecha_siniestro,
	       no_documento
      into _fecha_siniestro,
	       _no_documento
      from recrcmae
     where no_reclamo = _no_reclamo;
	 
	select nombre_abogado
      into _n_abogado
      from recaboga
     where cod_abogado = _cod_abogado;
    
    if _estatus = 1 then
		let _n_estatus = 'TRAMITE';
	elif _estatus = 2 then
		let _n_estatus = 'INVESTIGACION';
	elif _estatus = 3 then
		let _n_estatus = 'SUBROGACION';
	elif _estatus = 4 then
		let _n_estatus = 'ABOGADO';
	elif _estatus = 5 then
		let _n_estatus = 'ARREGLO DE PAGO';
	elif _estatus = 6 then
		let _n_estatus = 'INFRUCTUOSO';
	elif _estatus = 7 then
		let _n_estatus = 'RECUPERADO';
	end if
	
	return v_recupero,v_reclamo,_no_documento,v_tercero,_usuario,_pagado_reclamo,_monto_recuperado,_saldo,_n_estatus,_n_abogado,_fecha_recupero,v_fech_resol,_fecha_prescrip,
		   _fecha_envio,_fecha_siniestro with resume;
end foreach
end procedure